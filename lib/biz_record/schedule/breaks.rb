# frozen_string_literal: true

module BizRecord
  module Breaks
    include DateValues
    include TimeRanges

    def breaks_for(date)
      break_date = normalize_break_date(date)

      breaks
        .fetch(break_date, {})
        .map { |starts_at, ends_at| [starts_at, ends_at] }
        .sort_by { |starts_at, _ends_at| minutes_for(starts_at) }
    end

    def add_break(date, starts_at, ends_at)
      replace_breaks(date, breaks_for(date) + [[starts_at, ends_at]])
    end

    def replace_breaks(date, ranges)
      break_date = normalize_break_date(date)
      normalized_ranges = normalize_time_ranges(ranges, label: "breaks")

      update_breaks do |configured_breaks|
        if normalized_ranges.empty?
          configured_breaks.delete(break_date)
        else
          configured_breaks[break_date] = normalized_ranges.to_h
        end
      end
    end

    def remove_break(date, starts_at, ends_at)
      normalized_range = normalize_time_range(starts_at, ends_at, label: "breaks")
      remaining_ranges = breaks_for(date).reject { |range| range == normalized_range }

      replace_breaks(date, remaining_ranges)
    end

    def clear_breaks(date)
      replace_breaks(date, [])
    end

    def clear_all_breaks
      update_breaks(&:clear)
    end

    private

    def update_breaks
      next_configuration = configuration_data
      configured_breaks = deep_stringify_keys(next_configuration.fetch("breaks"))

      yield configured_breaks

      next_configuration["breaks"] = configured_breaks
      self.configuration = next_configuration
      self
    end

    def normalize_break_date(date)
      normalize_date_value(date, message: "break date must be a valid ISO 8601 date")
    end
  end
end
