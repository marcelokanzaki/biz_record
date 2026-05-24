# frozen_string_literal: true

require "test_helper"

module BizRecord
  class IntervalTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_creating_interval_touches_schedule_configuration
      schedule = create_schedule!

      schedule.intervals.create!(weekday: "sat", starts_at: "10:00", ends_at: "14:00")

      assert_equal({ "10:00" => "14:00" }, schedule.reload.hours.fetch("sat"))
    end

    def test_updating_interval_touches_schedule_configuration
      schedule = create_schedule!
      interval = schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      interval.update!(starts_at: "08:00", ends_at: "16:00")

      assert_equal({ "08:00" => "16:00" }, schedule.reload.hours.fetch("mon"))
    end

    def test_destroying_interval_touches_schedule_configuration
      schedule = create_schedule!
      interval = schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      interval.destroy!

      refute schedule.reload.hours.key?("mon")
    end

    def test_rejects_overlapping_intervals
      schedule = create_schedule!
      schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      interval = schedule.intervals.build(weekday: "mon", starts_at: "10:00", ends_at: "18:00")

      refute interval.valid?
      assert_includes interval.errors[:base], "hours cannot overlap"
    end

    def test_schedule_intervals_require_weekday
      schedule = create_schedule!
      interval = schedule.intervals.build(starts_at: "09:00", ends_at: "17:00")

      refute interval.valid?
      assert_includes interval.errors[:weekday], "can't be blank"
    end

    def test_day_intervals_reject_weekday
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")
      interval = shift.intervals.build(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      refute interval.valid?
      assert_includes interval.errors[:weekday], "must be blank"
    end
  end
end
