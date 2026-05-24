# frozen_string_literal: true

require "active_record"

module BizRecord
  class Interval < ActiveRecord::Base
    self.table_name = "biz_record_intervals"

    WEEKDAYS = BizRecord::Schedule::WeeklyHours::WEEKDAYS

    belongs_to :owner, polymorphic: true

    WEEKDAYS.each do |weekday|
      scope weekday, -> { where(weekday: weekday) }
    end

    validates :owner, presence: true
    validates :starts_at, :ends_at, presence: true
    validates :weekday, inclusion: { in: WEEKDAYS }, allow_nil: true

    validate :ends_after_starts
    validate :does_not_overlap

    after_save :sync_owner_schedule
    after_destroy :sync_owner_schedule

    def starts_at_string
      format_time(starts_at)
    end

    def ends_at_string
      format_time(ends_at)
    end

    def formatted_times
      [starts_at_string, ends_at_string]
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

    def sync_owner_schedule
      if owner.is_a?(BizRecord::Schedule)
        owner.sync_hours_from_intervals!(weekday)
      elsif owner.respond_to?(:sync_schedule_shifts!)
        owner.sync_schedule_shifts!
      end
    end

    def format_time(value)
      return if value.nil?

      value.respond_to?(:strftime) ? value.strftime("%H:%M") : String(value)
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
