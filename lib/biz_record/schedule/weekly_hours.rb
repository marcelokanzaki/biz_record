# frozen_string_literal: true

module BizRecord
  module WeeklyHours
    include TimeRanges

    WEEKDAYS = %w[sun mon tue wed thu fri sat].freeze

    def hours_for(weekday)
      day = normalize_weekday(weekday)

      hours
        .fetch(day, {})
        .map { |starts_at, ends_at| [starts_at, ends_at] }
        .sort_by { |starts_at, _ends_at| minutes_for(starts_at) }
    end

    def add_hours(weekday, starts_at, ends_at)
      replace_hours(weekday, hours_for(weekday) + [[starts_at, ends_at]])
    end

    def replace_hours(weekday, ranges)
      day = normalize_weekday(weekday)
      normalized_ranges = normalize_time_ranges(ranges, label: "hours")

      update_hours do |weekly_hours|
        if normalized_ranges.empty?
          weekly_hours.delete(day)
        else
          weekly_hours[day] = normalized_ranges.to_h
        end
      end
    end

    def remove_hours(weekday, starts_at, ends_at)
      normalized_range = normalize_time_range(starts_at, ends_at, label: "hours")
      remaining_ranges = hours_for(weekday).reject { |range| range == normalized_range }

      replace_hours(weekday, remaining_ranges)
    end

    def clear_hours(weekday)
      replace_hours(weekday, [])
    end

    private

    def update_hours
      next_configuration = configuration_data
      weekly_hours = deep_stringify_keys(next_configuration.fetch("hours"))

      yield weekly_hours

      next_configuration["hours"] = weekly_hours
      self.configuration = next_configuration
      self
    end

    def normalize_weekday(weekday)
      String(weekday).downcase.tap do |day|
        unless WEEKDAYS.include?(day)
          raise ArgumentError, "weekday must be one of: #{WEEKDAYS.join(", ")}"
        end
      end
    end
  end
end
