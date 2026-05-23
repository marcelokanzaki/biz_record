# frozen_string_literal: true

module BizRecord
  module WeeklyHours
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
      normalized_ranges = normalize_hour_ranges(ranges)

      update_hours do |weekly_hours|
        if normalized_ranges.empty?
          weekly_hours.delete(day)
        else
          weekly_hours[day] = normalized_ranges.to_h
        end
      end
    end

    def remove_hours(weekday, starts_at, ends_at)
      normalized_range = normalize_hour_range(starts_at, ends_at)
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

    def normalize_hour_ranges(ranges)
      normalized_ranges =
        case ranges
        when Hash
          ranges.map { |starts_at, ends_at| normalize_hour_range(starts_at, ends_at) }
        else
          Array(ranges).map do |range|
            unless range.respond_to?(:to_ary) && range.to_ary.size == 2
              raise ArgumentError, "hours must be pairs of start and end times"
            end

            normalize_hour_range(*range)
          end
        end

      normalized_ranges
        .sort_by { |starts_at, _ends_at| minutes_for(starts_at) }
        .tap { |sorted_ranges| ensure_ranges_do_not_overlap(sorted_ranges) }
    end

    def normalize_hour_range(starts_at, ends_at)
      normalized_starts_at = normalize_time(starts_at)
      normalized_ends_at = normalize_time(ends_at)

      unless minutes_for(normalized_starts_at) < minutes_for(normalized_ends_at)
        raise ArgumentError, "hours must start before they end"
      end

      [normalized_starts_at, normalized_ends_at]
    end

    def ensure_ranges_do_not_overlap(ranges)
      ranges.each_cons(2) do |(_previous_starts_at, previous_ends_at), (next_starts_at, _next_ends_at)|
        if minutes_for(previous_ends_at) > minutes_for(next_starts_at)
          raise ArgumentError, "hours cannot overlap"
        end
      end
    end

    def normalize_weekday(weekday)
      String(weekday).downcase.tap do |day|
        unless WEEKDAYS.include?(day)
          raise ArgumentError, "weekday must be one of: #{WEEKDAYS.join(", ")}"
        end
      end
    end

    def normalize_time(value)
      match = String(value).match(/\A(?<hour>\d{1,2}):(?<minute>\d{2})\z/)
      raise ArgumentError, "time must use HH:MM format" unless match

      hour = match[:hour].to_i
      minute = match[:minute].to_i

      if hour > 24 || minute > 59 || (hour == 24 && minute != 0)
        raise ArgumentError, "time must be within a day"
      end

      format("%02d:%02d", hour, minute)
    end

    def minutes_for(timestamp)
      hour, minute = timestamp.split(":").map(&:to_i)

      (hour * 60) + minute
    end
  end
end
