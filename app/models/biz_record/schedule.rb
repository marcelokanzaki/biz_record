# frozen_string_literal: true

require "active_record"
require "biz"
require "date"

module BizRecord
  class Schedule < ActiveRecord::Base
    include Schedule::Configuration
    include Schedule::Breaks
    include Schedule::Holidays
    include Schedule::Shifts
    include Schedule::WeeklyHours

    self.table_name = "biz_record_schedules"

    DEFAULT_KEY = "default"
    DEFAULT_TIME_ZONE = "Etc/UTC"
    DEFAULT_HOURS = BizRecord::Configuration::DEFAULT_HOURS
    DEFAULT_CONFIGURATION = {
      "hours" => DEFAULT_HOURS,
      "shifts" => {},
      "breaks" => {},
      "holidays" => []
    }.freeze

    def self.default_hours
      BizRecord.configuration.default_hours
    end

    def self.default_configuration
      {
        "hours" => default_hours,
        "shifts" => {},
        "breaks" => {},
        "holidays" => []
      }
    end

    belongs_to :schedulable, polymorphic: true, optional: false

    before_validation :apply_defaults

    validates :key, presence: true
    validates :schedulable, presence: true
    validates :time_zone, presence: true
    validates :configuration, presence: true
    validates :key, uniqueness: { scope: %i[schedulable_type schedulable_id] }

    has_many :intervals, as: :owner, class_name: "BizRecord::Interval", dependent: :delete_all
    has_many :days, class_name: "BizRecord::Day", dependent: :destroy, inverse_of: :schedule
    has_many :shift_days, -> { order(:date) }, class_name: "BizRecord::Days::Shift", inverse_of: :schedule

    after_create :create_intervals_from_hours
    after_create :create_days_from_shifts

    validate :time_zone_exists
    validate :configuration_builds_biz_schedule

    def to_biz_schedule
      Biz::Schedule.new do |config|
        config.hours = biz_hours
        config.shifts = biz_date_hours("shifts")
        config.breaks = biz_date_hours("breaks")
        config.holidays = configuration_data.fetch("holidays").map { |date| ::Date.iso8601(String(date)) }
        config.time_zone = time_zone
      end
    end

    def hours
      configuration_data.fetch("hours")
    end

    def shifts
      configuration_data.fetch("shifts")
    end

    def breaks
      configuration_data.fetch("breaks")
    end

    def holidays
      configuration_data.fetch("holidays")
    end

    def sync_hours_from_intervals!(weekday)
      ranges = intervals
        .where(weekday: weekday)
        .order(:starts_at)
        .map(&:formatted_times)

      replace_hours(weekday, ranges)
      save!
    end

    def sync_shifts_from_day!(day)
      ranges = day.intervals.order(:starts_at).map(&:formatted_times)

      replace_shifts(day.date, ranges)
      save!
    end

    private

    def apply_defaults
      self.key = DEFAULT_KEY if key.nil? || key.empty?
      self.time_zone = DEFAULT_TIME_ZONE if time_zone.nil? || time_zone.empty?
      self.configuration = configuration_data
    end

    def configuration_data
      deep_stringify_keys(self.class.default_configuration).merge(deep_stringify_keys(self[:configuration] || {}))
    end

    def create_intervals_from_hours
      hours.each do |weekday, ranges|
        ranges.each do |starts_at, ends_at|
          intervals.create!(
            weekday: weekday,
            starts_at: starts_at,
            ends_at: ends_at
          )
        end
      end
    end

    def create_days_from_shifts
      shifts.map { |date, ranges| [date, ranges] }.each do |date, ranges|
        shift = shift_days.create!(date: date)

        ranges.each do |starts_at, ends_at|
          shift.intervals.create!(starts_at: starts_at, ends_at: ends_at)
        end
      end
    end

    def biz_hours
      hours.each_with_object({}) do |(weekday, ranges), converted|
        converted[weekday.to_sym] = stringify_ranges(ranges)
      end
    end

    def biz_date_hours(key)
      configuration_data.fetch(key).each_with_object({}) do |(date, ranges), converted|
        converted[::Date.iso8601(String(date))] = stringify_ranges(ranges)
      end
    end

    def stringify_ranges(ranges)
      ranges.each_with_object({}) do |(starts_at, ends_at), converted|
        converted[String(starts_at)] = String(ends_at)
      end
    end

    def deep_stringify_keys(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, child), converted|
          converted[String(key)] = deep_stringify_keys(child)
        end
      when Array
        value.map { |child| deep_stringify_keys(child) }
      else
        value
      end
    end

    def time_zone_exists
      TZInfo::Timezone.get(time_zone)
    rescue TZInfo::InvalidTimezoneIdentifier
      errors.add(:time_zone, "is not a valid IANA time zone")
    end

    def configuration_builds_biz_schedule
      to_biz_schedule
    rescue Biz::Error::Configuration, ArgumentError, KeyError, TypeError, NoMethodError => error
      errors.add(:configuration, error.message)
    end
  end
end
