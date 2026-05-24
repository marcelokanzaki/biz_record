# frozen_string_literal: true

require "active_record"
require "biz"
require "date"

module BizRecord
  class Schedule < ActiveRecord::Base
    include Timezone

    self.table_name = "biz_record_schedules"

    DEFAULT_KEY = "default"

    def self.default_hours
      BizRecord.default_hours
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
    validates :configuration, presence: true
    validates :key, uniqueness: { scope: %i[schedulable_type schedulable_id] }

    has_many :intervals, as: :owner, class_name: "BizRecord::Interval", dependent: :delete_all
    has_many :days, class_name: "BizRecord::Day", dependent: :destroy, inverse_of: :schedule
    has_many :shift_days, -> { order(:date) }, class_name: "BizRecord::Days::Shift", inverse_of: :schedule
    has_many :break_days, -> { order(:date) }, class_name: "BizRecord::Days::Break", inverse_of: :schedule
    has_many :holiday_days, -> { order(:date) }, class_name: "BizRecord::Days::Holiday", inverse_of: :schedule

    after_touch :refresh_configuration_from_associations

    def to_biz_schedule
      Biz::Schedule.new do |config|
        config.hours = biz_hours
        config.shifts = biz_date_hours("shifts")
        config.breaks = biz_date_hours("breaks")
        config.holidays = biz_holidays
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

      BizRecord::WEEKDAYS.each_with_object({}) do |weekday, configured_hours|
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
      self.class.default_configuration.merge(stringify_configuration_keys(self[:configuration] || {}))
    end

    def biz_hours
      symbolize_weekdays(hours)
    end

    def biz_date_hours(key)
      date_hours = configuration_data.fetch(key)
      return date_hours unless date_hours.respond_to?(:to_h)

      date_hours.to_h.each_with_object({}) do |(date, ranges), converted|
        converted[date_value(date)] = ranges
      end
    end

    def biz_holidays
      holidays.map { |date| date_value(date) }
    end

    def symbolize_weekdays(configured_hours)
      return configured_hours unless configured_hours.respond_to?(:to_h)

      configured_hours.to_h.each_with_object({}) do |(weekday, ranges), converted|
        converted[weekday.respond_to?(:to_sym) ? weekday.to_sym : weekday] = ranges
      end
    end

    def date_value(date)
      return date.to_date if date.respond_to?(:to_date)
      return ::Date.iso8601(date) if date.is_a?(String)

      date
    rescue ArgumentError
      date
    end

    def stringify_configuration_keys(configuration)
      return {} unless configuration.respond_to?(:to_h)

      configuration.to_h.each_with_object({}) do |(key, value), converted|
        converted[String(key)] = value
      end
    end
  end
end
