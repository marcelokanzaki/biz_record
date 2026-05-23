# frozen_string_literal: true

module BizRecord
  class Configuration
    include BizRecord::TimeRanges

    DEFAULT_HOURS = {
      "mon" => { "09:00" => "17:00" },
      "tue" => { "09:00" => "17:00" },
      "wed" => { "09:00" => "17:00" },
      "thu" => { "09:00" => "17:00" },
      "fri" => { "09:00" => "17:00" }
    }.each_value(&:freeze).freeze
    WEEKDAYS = %w[sun mon tue wed thu fri sat].freeze

    attr_reader :default_hours

    def initialize
      self.default_hours = DEFAULT_HOURS
    end

    def default_hours=(hours)
      @default_hours = deep_freeze(normalize_weekly_hours(hours))
    end

    private

    def normalize_weekly_hours(configured_hours)
      unless configured_hours.respond_to?(:to_h)
        raise ArgumentError, "default_hours must be a hash"
      end

      deep_stringify_keys(configured_hours.to_h).each_with_object({}) do |(weekday, ranges), normalized|
        normalized_ranges = normalize_time_ranges(ranges, label: "default_hours")

        next if normalized_ranges.empty?

        normalized[normalize_weekday(weekday)] = normalized_ranges.to_h
      end
    end

    def normalize_weekday(weekday)
      String(weekday).downcase.tap do |day|
        unless WEEKDAYS.include?(day)
          raise ArgumentError, "weekday must be one of: #{WEEKDAYS.join(", ")}"
        end
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

    def deep_freeze(value)
      case value
      when Hash
        value.each_value { |child| deep_freeze(child) }
      when Array
        value.each { |child| deep_freeze(child) }
      end

      value.freeze
    end
  end
end
