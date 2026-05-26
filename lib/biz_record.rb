require "active_support/lazy_load_hooks"
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

    def reset_configuration!
      @default_hours = nil
    end

    def install_schedulable
      ActiveSupport.on_load(:active_record) do
        include BizRecord::Schedulable
      end
    end
  end
end
