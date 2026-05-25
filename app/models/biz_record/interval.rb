# frozen_string_literal: true

require "active_record"

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

    validate :weekday_matches_owner
    validate :ends_after_starts
    validate :does_not_overlap

    after_save    -> { owner.touch }
    after_destroy -> { owner.touch }

    def starts_at_string
      starts_at&.strftime("%H:%M")
    end

    def ends_at_string
      ends_at&.strftime("%H:%M")
    end

    private

    def ends_after_starts
      return if starts_at.blank? || ends_at.blank?

      errors.add(:ends_at, "must be after starts at") unless minutes_for(ends_at) > minutes_for(starts_at)
    end

    def does_not_overlap
      return if owner.blank? || starts_at.blank? || ends_at.blank?

      intervals = owner.intervals.where(weekday: weekday)
      intervals = intervals.where.not(id: id) if persisted?

      if intervals.any? { |interval| overlaps?(interval) }
        errors.add(:base, "hours cannot overlap")
      end
    end

    def overlaps?(other)
      minutes_for(starts_at) < minutes_for(other.ends_at) && minutes_for(ends_at) > minutes_for(other.starts_at)
    end

    def weekday_matches_owner
      return if owner.blank?

      if owner.is_a?(BizRecord::Schedule)
        errors.add(:weekday, "can't be blank") if weekday.blank?
      elsif weekday.present?
        errors.add(:weekday, "must be blank")
      end
    end

    def minutes_for(value)
      if value.respond_to?(:hour)
        (value.hour * 60) + value.min
      else
        hour, minute = String(value).split(":").map(&:to_i)

        (hour * 60) + minute
      end
    end
  end
end
