module BizRecord
  class Schedule < ActiveRecord::Base
    include BizSchedule, Configuration, TimeZone, Key, Reload

    self.table_name = "biz_record_schedules"

    belongs_to :schedulable, polymorphic: true, optional: false

    has_many :intervals,    -> { chronological }, class_name: "BizRecord::Interval", as: :owner, dependent: :delete_all
    has_many :days,         -> { chronological }, class_name: "BizRecord::Day", dependent: :delete_all, inverse_of: :schedule
    has_many :shift_days,   -> { chronological }, class_name: "BizRecord::Days::Shift", inverse_of: :schedule
    has_many :break_days,   -> { chronological }, class_name: "BizRecord::Days::Break", inverse_of: :schedule
    has_many :holiday_days, -> { chronological }, class_name: "BizRecord::Days::Holiday", inverse_of: :schedule

    validates :schedulable, presence: true
  end
end
