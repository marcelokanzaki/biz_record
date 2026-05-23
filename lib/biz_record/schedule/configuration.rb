# frozen_string_literal: true

module BizRecord::Schedule::Configuration
  include BizRecord::DateValues
  include BizRecord::TimeRanges

  CONFIGURATION_KEYS = %w[hours shifts breaks holidays].freeze

  def to_biz_configuration
    {
      "hours" => deep_stringify_keys(hours),
      "shifts" => deep_stringify_keys(shifts),
      "breaks" => deep_stringify_keys(breaks),
      "holidays" => holidays.dup
    }
  end

  alias biz_configuration to_biz_configuration

  def replace_configuration(attributes = {})
    normalized_attributes = normalize_configuration_attributes(attributes)

    self.configuration = {
      "hours" => normalize_weekly_hours_configuration(
        normalized_attributes.fetch("hours", self.class::DEFAULT_HOURS)
      ),
      "shifts" => normalize_date_ranges_configuration(
        normalized_attributes.fetch("shifts", {}),
        label: "shifts",
        date_message: "shift date must be a valid ISO 8601 date"
      ),
      "breaks" => normalize_date_ranges_configuration(
        normalized_attributes.fetch("breaks", {}),
        label: "breaks",
        date_message: "break date must be a valid ISO 8601 date"
      ),
      "holidays" => normalize_holidays(normalized_attributes.fetch("holidays", []))
    }

    self
  end

  private

  def normalize_configuration_attributes(attributes)
    unless attributes.respond_to?(:to_h)
      raise ArgumentError, "configuration must be a hash"
    end

    normalized_attributes = deep_stringify_keys(attributes.to_h)
    unknown_keys = normalized_attributes.keys - CONFIGURATION_KEYS

    if unknown_keys.any?
      raise ArgumentError, "configuration contains unknown keys: #{unknown_keys.sort.join(", ")}"
    end

    normalized_attributes
  end

  def normalize_weekly_hours_configuration(configured_hours)
    deep_stringify_keys(configured_hours).each_with_object({}) do |(weekday, ranges), normalized|
      normalized_ranges = normalize_time_ranges(ranges, label: "hours")

      next if normalized_ranges.empty?

      normalized[normalize_weekday(weekday)] = normalized_ranges.to_h
    end
  end

  def normalize_date_ranges_configuration(configured_ranges, label:, date_message:)
    deep_stringify_keys(configured_ranges).each_with_object({}) do |(date, ranges), normalized|
      normalized_ranges = normalize_time_ranges(ranges, label: label)

      next if normalized_ranges.empty?

      normalized[normalize_date_value(date, message: date_message)] = normalized_ranges.to_h
    end
  end
end
