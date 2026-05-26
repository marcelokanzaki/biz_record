module BizRecord
  class Schedule < ActiveRecord::Base
    include Key, Timezone, ConfigurationBundle, BizSchedule

    self.table_name = "biz_record_schedules"

    belongs_to :schedulable, polymorphic: true, optional: false

    has_many :intervals, as: :owner, class_name: "BizRecord::Interval", dependent: :delete_all
    has_many :days, class_name: "BizRecord::Day", dependent: :destroy, inverse_of: :schedule
    has_many :shift_days, -> { order(date: :asc) }, class_name: "BizRecord::Days::Shift", inverse_of: :schedule
    has_many :break_days, -> { order(date: :asc) }, class_name: "BizRecord::Days::Break", inverse_of: :schedule
    has_many :holiday_days, -> { order(date: :asc) }, class_name: "BizRecord::Days::Holiday", inverse_of: :schedule

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
      reset_biz_schedule
      self[:configuration] = self.class.default_configuration.deep_stringify_keys.deep_merge(new_configuration.deep_stringify_keys)
    end

    def reload(*args)
      super.tap { reset_biz_schedule }
    end

    private

    def set_default_configuration
      self.configuration = self.class.default_configuration unless configuration.present?
    end
  end
end
