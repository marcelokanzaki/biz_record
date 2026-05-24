# frozen_string_literal: true

require "date"

module BizRecord
  module DateValues
    private

    def normalize_date_value(value, message:)
      case value
      when ::Date
        value.iso8601
      when ::Time
        ::Date.new(value.year, value.month, value.day).iso8601
      else
        if value.respond_to?(:year) && value.respond_to?(:month) && value.respond_to?(:day)
          ::Date.new(value.year, value.month, value.day).iso8601
        else
          ::Date.iso8601(String(value)).iso8601
        end
      end
    rescue ArgumentError
      raise ArgumentError, message
    end
  end
end
