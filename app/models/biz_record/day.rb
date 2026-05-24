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

    def date_string
      date&.iso8601
    end
  end
end
