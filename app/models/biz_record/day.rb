# frozen_string_literal: true

require "active_record"

module BizRecord
  class Day < ActiveRecord::Base
    self.table_name = "biz_record_days"

    belongs_to :schedule, class_name: "BizRecord::Schedule", inverse_of: :days

    validates :schedule, presence: true
    validates :date, presence: true
    validates :type, presence: true
    validates :date, uniqueness: { scope: %i[schedule_id type] }

    after_save :touch_schedule
    after_destroy :touch_schedule

    def date_string
      date&.iso8601
    end

    private

    def touch_schedule
      return if schedule.blank? || schedule.destroyed? || destroyed_by_association

      schedule.touch
    end
  end
end
