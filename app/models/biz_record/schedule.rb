# frozen_string_literal: true

require "active_record"
require "biz"
require "date"

module BizRecord
  class Schedule < ActiveRecord::Base
    include Timezone, ConfigurationBundle, BizSchedule

    self.table_name = "biz_record_schedules"

    DEFAULT_KEY = "default"

    def self.default_hours
      BizRecord.default_hours
    end

    def self.default_configuration
      {
        "hours" => default_hours,
        "shifts" => {},
        "breaks" => {},
        "holidays" => []
      }
    end

    belongs_to :schedulable, polymorphic: true, optional: false

    before_validation :apply_defaults

    validates :key, presence: true
    validates :schedulable, presence: true
    validates :configuration, presence: true
    validates :key, uniqueness: { scope: %i[schedulable_type schedulable_id] }

    has_many :intervals, as: :owner, class_name: "BizRecord::Interval", dependent: :delete_all
    has_many :days, class_name: "BizRecord::Day", dependent: :destroy, inverse_of: :schedule
    has_many :shift_days, -> { order(:date) }, class_name: "BizRecord::Days::Shift", inverse_of: :schedule
    has_many :break_days, -> { order(:date) }, class_name: "BizRecord::Days::Break", inverse_of: :schedule
    has_many :holiday_days, -> { order(:date) }, class_name: "BizRecord::Days::Holiday", inverse_of: :schedule

    def hours
      configuration_data.fetch("hours")
    end

    def shifts
      configuration_data.fetch("shifts")
    end

    def breaks
      configuration_data.fetch("breaks")
    end

    def holidays
      configuration_data.fetch("holidays")
    end

    private

    def apply_defaults
      self.key = DEFAULT_KEY if key.nil? || key.empty?
      self.configuration = configuration_data
    end

    def configuration_data
      self.class.default_configuration.merge(stringify_configuration_keys(self[:configuration] || {}))
    end

    def stringify_configuration_keys(configuration)
      return {} unless configuration.respond_to?(:to_h)

      configuration.to_h.each_with_object({}) do |(key, value), converted|
        converted[String(key)] = value
      end
    end
  end
end
