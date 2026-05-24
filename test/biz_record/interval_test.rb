# frozen_string_literal: true

require "test_helper"

module BizRecord
  class IntervalTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_schedule_creates_intervals_from_hours
      schedule = create_schedule!

      assert_equal [["09:00", "17:00"]], schedule.intervals.mon.map(&:formatted_times)
    end

    def test_creating_interval_syncs_schedule_hours
      schedule = create_schedule!

      schedule.intervals.create!(weekday: "sat", starts_at: "10:00", ends_at: "14:00")

      assert_equal [["10:00", "14:00"]], schedule.reload.hours_for(:sat)
    end

    def test_updating_interval_syncs_schedule_hours
      schedule = create_schedule!
      interval = schedule.intervals.mon.first

      interval.update!(starts_at: "08:00", ends_at: "16:00")

      assert_equal [["08:00", "16:00"]], schedule.reload.hours_for(:mon)
    end

    def test_destroying_interval_syncs_schedule_hours
      schedule = create_schedule!
      interval = schedule.intervals.mon.first

      interval.destroy!

      assert_equal [], schedule.reload.hours_for(:mon)
    end

    def test_rejects_overlapping_intervals
      schedule = create_schedule!

      interval = schedule.intervals.build(weekday: "mon", starts_at: "10:00", ends_at: "18:00")

      refute interval.valid?
      assert_includes interval.errors[:base], "hours cannot overlap"
    end
  end
end
