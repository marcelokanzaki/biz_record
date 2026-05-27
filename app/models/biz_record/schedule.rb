module BizRecord
  class Schedule < ActiveRecord::Base
    self.table_name = "biz_record_schedules"

    define_model_callbacks :configuration_changed, :time_zone_changed, :reloaded, only: :after

    include Key, TimeZone, ConfigurationBundle, BizSchedule

    belongs_to :schedulable, polymorphic: true, optional: false

    has_many :intervals,    -> { chronological }, class_name: "BizRecord::Interval", as: :owner, dependent: :delete_all
    has_many :days,         -> { chronological }, class_name: "BizRecord::Day", dependent: :destroy, inverse_of: :schedule
    has_many :shift_days,   -> { chronological }, class_name: "BizRecord::Days::Shift", inverse_of: :schedule
    has_many :break_days,   -> { chronological }, class_name: "BizRecord::Days::Break", inverse_of: :schedule
    has_many :holiday_days, -> { chronological }, class_name: "BizRecord::Days::Holiday", inverse_of: :schedule

    validates :schedulable, presence: true
    validates :configuration, presence: true

    before_validation :set_default_configuration

    delegate :in_hours?, :on_break?, :on_holiday?, :time, :within, :periods, to: :biz_schedule

    def self.default_configuration
      {
        "hours"    => BizRecord.default_hours,
        "shifts"   => {},
        "breaks"   => {},
        "holidays" => []
      }
    end

    def configuration=(new_configuration)
      run_callbacks :configuration_changed do
        self[:configuration] = self.class.default_configuration.deep_stringify_keys.deep_merge(new_configuration.deep_stringify_keys)
      end
    end

    def reload(*args)
      run_callbacks(:reloaded) { super }
    end

    private

    def set_default_configuration
      self.configuration = self.class.default_configuration unless configuration.present?
    end
  end
end
