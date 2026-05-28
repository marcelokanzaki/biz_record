require "biz_record/version"
require "biz_record/engine"

module BizRecord
  WEEKDAYS = %w[sun mon tue wed thu fri sat].freeze

  DEFAULT_HOURS = {
    mon: { "09:00" => "17:00" },
    tue: { "09:00" => "17:00" },
    wed: { "09:00" => "17:00" },
    thu: { "09:00" => "17:00" },
    fri: { "09:00" => "17:00" }
  }.transform_values(&:freeze).freeze

  DEFAULT_TIME_ZONE = "Etc/UTC"

  DEFAULT_KEY = "default"

  class << self
    attr_writer :default_hours

    def configure
      yield self
    end

    def configuration
      self
    end

    def default_hours
      @default_hours || DEFAULT_HOURS
    end

    def default_time_zone
      Time.find_zone!(Rails.application.config.time_zone.presence || DEFAULT_TIME_ZONE).tzinfo.identifier
    end

    def reset_configuration!
      @default_hours = nil
    end
  end
end
