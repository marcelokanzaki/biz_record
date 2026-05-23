# frozen_string_literal: true

module BizRecord
  class Schedule
    module Holidays
      include DateValues

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
        normalize_date_value(date, message: "holiday must be a valid ISO 8601 date")
      end
    end
  end
end
