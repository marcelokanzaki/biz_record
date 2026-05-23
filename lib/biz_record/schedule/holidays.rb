# frozen_string_literal: true

require "date"

module BizRecord
  module Holidays
    def add_holiday(date)
      replace_holidays(holidays + [date])
    end

    def replace_holidays(dates)
      update_holidays(normalize_holidays(dates))
    end

    def remove_holiday(date)
      normalized_date = normalize_holiday(date)

      replace_holidays(holidays.reject { |holiday| holiday == normalized_date })
    end

    def clear_holidays
      replace_holidays([])
    end

    def holiday?(date)
      holidays.include?(normalize_holiday(date))
    end

    private

    def update_holidays(dates)
      next_configuration = configuration_data
      next_configuration["holidays"] = dates
      self.configuration = next_configuration
      self
    end

    def normalize_holidays(dates)
      Array(dates).map { |date| normalize_holiday(date) }.uniq.sort
    end

    def normalize_holiday(date)
      case date
      when ::Date
        date.iso8601
      when ::Time
        ::Date.new(date.year, date.month, date.day).iso8601
      else
        if date.respond_to?(:year) && date.respond_to?(:month) && date.respond_to?(:day)
          ::Date.new(date.year, date.month, date.day).iso8601
        else
          ::Date.iso8601(String(date)).iso8601
        end
      end
    rescue ArgumentError
      raise ArgumentError, "holiday must be a valid ISO 8601 date"
    end
  end
end
