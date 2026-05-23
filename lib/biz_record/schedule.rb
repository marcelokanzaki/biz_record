# frozen_string_literal: true

require "date"

module BizRecord
  class Schedule < ActiveRecord::Base
    include Breaks
    include Holidays
    include Shifts
    include WeeklyHours

    self.table_name = "biz_record_schedules"

    DEFAULT_KEY = "default"
    DEFAULT_TIME_ZONE = "Etc/UTC"
    DEFAULT_HOURS = {
      "mon" => { "09:00" => "17:00" },
      "tue" => { "09:00" => "17:00" },
      "wed" => { "09:00" => "17:00" },
      "thu" => { "09:00" => "17:00" },
      "fri" => { "09:00" => "17:00" }
    }.freeze
    DEFAULT_CONFIGURATION = {
      "hours" => DEFAULT_HOURS,
      "shifts" => {},
      "breaks" => {},
      "holidays" => []
    }.freeze

    belongs_to :schedulable, polymorphic: true, optional: true

    before_validation :apply_defaults

    validates :key, presence: true
    validates :time_zone, presence: true
    validates :configuration, presence: true
    validates :key, uniqueness: { scope: %i[schedulable_type schedulable_id] }

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

    alias to_schedule to_biz_schedule

    def to_biz_config
      {
        hours: biz_hours,
        shifts: biz_date_hours("shifts"),
        breaks: biz_date_hours("breaks"),
        holidays: configuration_data.fetch("holidays").map { |date| ::Date.iso8601(String(date)) },
        time_zone: time_zone
      }
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

    def configuration_data
      deep_stringify_keys(DEFAULT_CONFIGURATION).merge(deep_stringify_keys(self[:configuration] || {}))
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
