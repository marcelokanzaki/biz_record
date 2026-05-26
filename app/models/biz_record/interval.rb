module BizRecord
  class Interval < ActiveRecord::Base
    self.table_name = "biz_record_intervals"

    WEEKDAYS = BizRecord::WEEKDAYS

    belongs_to :owner, polymorphic: true

    WEEKDAYS.each do |weekday|
      scope weekday, -> { where(weekday: weekday) }
    end

    validates :owner, presence: true
    validates :starts_at, :ends_at, presence: true
    validates :weekday, inclusion: { in: WEEKDAYS }, allow_nil: true

    validate :weekday_attribte_is_for_schedule_intervals
    validate :ends_after_starts
    validate :does_not_overlap

    after_save    -> { owner.touch }
    after_destroy -> { owner.touch }

    def formatted_starts_at
      starts_at&.strftime("%H:%M")
    end

    def formatted_ends_at
      ends_at&.strftime("%H:%M")
    end

    def overlaps?(other)
      starts_at < other.ends_at && ends_at > other.starts_at
    end

    private

    def weekday_attribte_is_for_schedule_intervals
      return if owner.blank?

      if owner.is_a?(BizRecord::Schedule)
        errors.add(:weekday, "can't be blank") if weekday.blank?
      elsif weekday.present?
        errors.add(:weekday, "must be blank")
      end
    end

    def ends_after_starts
      if starts_at.present? && ends_at.present? && ends_at <= starts_at
        errors.add(:ends_at, "must be after starts at")
      end
    end

    def does_not_overlap
      return if owner.blank? || starts_at.blank? || ends_at.blank?

      sibling_intervals = owner.intervals.where(weekday: weekday)
      sibling_intervals = sibling_intervals.where.not(id: id) if persisted?

      if sibling_intervals.any? { |interval| overlaps?(interval) }
        errors.add(:base, "hours cannot overlap")
      end
    end
  end
end
