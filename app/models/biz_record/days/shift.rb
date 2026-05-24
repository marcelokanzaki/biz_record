# frozen_string_literal: true

module BizRecord
  module Days
    class Shift < BizRecord::Day
      has_many :intervals, as: :owner, class_name: "BizRecord::Interval", dependent: :delete_all

      after_update :sync_schedule_shifts_after_date_change, if: :saved_change_to_date?
      after_destroy :clear_schedule_shifts

      def sync_schedule_shifts!
        schedule.sync_shifts_from_day!(self)
      end

      private

      def sync_schedule_shifts_after_date_change
        previous_date, = saved_change_to_date

        schedule.clear_shifts(previous_date)
        sync_schedule_shifts!
      end

      def clear_schedule_shifts
        return if schedule.blank? || destroyed_by_association

        schedule.clear_shifts(date)
        schedule.save!
      end
    end
  end
end
