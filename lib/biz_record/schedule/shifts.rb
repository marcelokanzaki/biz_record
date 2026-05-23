# frozen_string_literal: true

module BizRecord
  module Shifts
    include DateValues
    include TimeRanges

    def shifts_for(date)
      shift_date = normalize_shift_date(date)

      shifts
        .fetch(shift_date, {})
        .map { |starts_at, ends_at| [starts_at, ends_at] }
        .sort_by { |starts_at, _ends_at| minutes_for(starts_at) }
    end

    def add_shift(date, starts_at, ends_at)
      replace_shifts(date, shifts_for(date) + [[starts_at, ends_at]])
    end

    def replace_shifts(date, ranges)
      shift_date = normalize_shift_date(date)
      normalized_ranges = normalize_time_ranges(ranges, label: "shifts")

      update_shifts do |configured_shifts|
        if normalized_ranges.empty?
          configured_shifts.delete(shift_date)
        else
          configured_shifts[shift_date] = normalized_ranges.to_h
        end
      end
    end

    def remove_shift(date, starts_at, ends_at)
      normalized_range = normalize_time_range(starts_at, ends_at, label: "shifts")
      remaining_ranges = shifts_for(date).reject { |range| range == normalized_range }

      replace_shifts(date, remaining_ranges)
    end

    def clear_shifts(date)
      replace_shifts(date, [])
    end

    def clear_all_shifts
      update_shifts(&:clear)
    end

    private

    def update_shifts
      next_configuration = configuration_data
      configured_shifts = deep_stringify_keys(next_configuration.fetch("shifts"))

      yield configured_shifts

      next_configuration["shifts"] = configured_shifts
      self.configuration = next_configuration
      self
    end

    def normalize_shift_date(date)
      normalize_date_value(date, message: "shift date must be a valid ISO 8601 date")
    end
  end
end
