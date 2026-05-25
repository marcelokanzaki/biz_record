# frozen_string_literal: true

require "active_record"
require "biz"
require "date"

module BizRecord
  class Schedule < ActiveRecord::Base
    include Timezone, ConfigurationBundle, BizSchedule

    self.table_name = "biz_record_schedules"

    DEFAULT_KEY = "default"

    belongs_to :schedulable, polymorphic: true, optional: false

    has_many :intervals, as: :owner, class_name: "BizRecord::Interval", dependent: :delete_all
    has_many :days, class_name: "BizRecord::Day", dependent: :destroy, inverse_of: :schedule
    has_many :shift_days, -> { order(date: :asc) }, class_name: "BizRecord::Days::Shift", inverse_of: :schedule
    has_many :break_days, -> { order(date: :asc) }, class_name: "BizRecord::Days::Break", inverse_of: :schedule
    has_many :holiday_days, -> { order(date: :asc) }, class_name: "BizRecord::Days::Holiday", inverse_of: :schedule

    validates :key, presence: true
    validates :schedulable, presence: true
    validates :configuration, presence: true
    validates :key, uniqueness: { scope: %i[schedulable_type schedulable_id] }

    before_validation :set_default_key
    before_validation :set_default_configuration

    def self.default_configuration
      {
        "hours" => BizRecord.default_hours,
        "shifts" => {},
        "breaks" => {},
        "holidays" => []
      }
    end

    def configuration=(new_configuration)
      self[:configuration] = self.class.default_configuration.deep_stringify_keys.deep_merge(new_configuration.deep_stringify_keys)
    end

    private

    def set_default_key
      self.key = DEFAULT_KEY unless key.present?
    end

    def set_default_configuration
      self.configuration = self.class.default_configuration unless configuration.present?
    end
  end
end
