# frozen_string_literal: true

module BizRecord
  module TimeRanges
    private

    def normalize_time_ranges(ranges, label:)
      normalized_ranges =
        case ranges
        when Hash
          ranges.map { |starts_at, ends_at| normalize_time_range(starts_at, ends_at, label: label) }
        else
          Array(ranges).map do |range|
            unless range.respond_to?(:to_ary) && range.to_ary.size == 2
              raise ArgumentError, "#{label} must be pairs of start and end times"
            end

            normalize_time_range(*range, label: label)
          end
        end

      normalized_ranges
        .sort_by { |starts_at, _ends_at| minutes_for(starts_at) }
        .tap { |sorted_ranges| ensure_time_ranges_do_not_overlap(sorted_ranges, label: label) }
    end

    def normalize_time_range(starts_at, ends_at, label:)
      normalized_starts_at = normalize_time(starts_at)
      normalized_ends_at = normalize_time(ends_at)

      unless minutes_for(normalized_starts_at) < minutes_for(normalized_ends_at)
        raise ArgumentError, "#{label} must start before they end"
      end

      [normalized_starts_at, normalized_ends_at]
    end

    def ensure_time_ranges_do_not_overlap(ranges, label:)
      ranges.each_cons(2) do |(_previous_starts_at, previous_ends_at), (next_starts_at, _next_ends_at)|
        raise ArgumentError, "#{label} cannot overlap" if minutes_for(previous_ends_at) > minutes_for(next_starts_at)
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
