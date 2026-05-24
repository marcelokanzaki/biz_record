# frozen_string_literal: true

require "active_record"
require "biz"
require "date"

module BizRecord
  class Schedule < ActiveRecord::Base
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
    has_many :break_days, -> { order(:date) }, class_name: "BizRecord::Days::Break", inverse_of: :schedule
    has_many :holiday_days, -> { order(:date) }, class_name: "BizRecord::Days::Holiday", inverse_of: :schedule

    after_touch :refresh_configuration_from_associations

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

    private

    def apply_defaults
      self.key = DEFAULT_KEY if key.nil? || key.empty?
      self.time_zone = DEFAULT_TIME_ZONE if time_zone.nil? || time_zone.empty?
      self.configuration = configuration_data
    end

    def refresh_configuration_from_associations
      update_column(:configuration, configuration_from_associations)
    end

    def configuration_from_associations
      {
        "hours" => weekly_hours_configuration,
        "shifts" => date_hours_configuration(BizRecord::Days::Shift),
        "breaks" => date_hours_configuration(BizRecord::Days::Break),
        "holidays" => holidays_configuration
      }
    end

    def weekly_hours_configuration
      intervals_by_weekday = BizRecord::Interval
        .where(owner_type: self.class.name, owner_id: id)
        .where.not(weekday: nil)
        .order(:starts_at)
        .group_by(&:weekday)

      BizRecord::Configuration::WEEKDAYS.each_with_object({}) do |weekday, configured_hours|
        weekday_intervals = intervals_by_weekday.fetch(weekday, [])
        next if weekday_intervals.empty?

        configured_hours[weekday] = time_ranges_for(weekday_intervals)
      end
    end

    def date_hours_configuration(day_class)
      days = day_class
        .where(schedule_id: id)
        .order(:date)
        .includes(:intervals)

      days.each_with_object({}) do |day, configured_hours|
        day_intervals = day.intervals.sort_by(&:starts_at)
        next if day_intervals.empty?

        configured_hours[day.date_string] = time_ranges_for(day_intervals)
      end
    end

    def holidays_configuration
      BizRecord::Days::Holiday
        .where(schedule_id: id)
        .order(:date)
        .map(&:date_string)
        .uniq
        .sort
    end

    def time_ranges_for(intervals)
      intervals.each_with_object({}) do |interval, time_ranges|
        time_ranges[interval.starts_at_string] = interval.ends_at_string
      end
    end

    def configuration_data
      deep_stringify_keys(self.class.default_configuration).merge(deep_stringify_keys(self[:configuration] || {}))
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
