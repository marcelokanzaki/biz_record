module BizRecord
  class Day < ActiveRecord::Base
    self.table_name = "biz_record_days"

    VALID_TYPES = %w[
      BizRecord::Days::Shift
      BizRecord::Days::Break
      BizRecord::Days::Holiday
    ].freeze

    belongs_to :schedule, class_name: "BizRecord::Schedule", inverse_of: :days

    scope :chronological, -> { order(date: :asc) }
    scope :future,        -> { where(date: Time.current..) }
    scope :past,          -> { where(date: ...Time.current) }

    validates :schedule, presence: true
    validates :date, presence: true
    validates :type, presence: true
    validates :type, inclusion: { in: VALID_TYPES }
    validates :date, uniqueness: { scope: %i[schedule_id type] }

    after_save    -> { schedule.touch }
    after_destroy -> { schedule.touch }
    after_touch   -> { schedule.touch }
  end
end
