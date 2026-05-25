# frozen_string_literal: true

require "test_helper"

module BizRecord
  class IntervalTest < ActiveSupport::TestCase
    setup do
      Schedule.delete_all
      Account.delete_all
    end

    test "create touches schedule" do
      schedule = create_schedule!

      assert_changes -> { schedule.updated_at } do
        schedule.intervals.create!(weekday: "sat", starts_at: "10:00", ends_at: "14:00")
      end
    end

    test "update touches schedule" do
      schedule = create_schedule!
      interval = schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      assert_changes -> { schedule.updated_at } do
        interval.update!(starts_at: "08:00", ends_at: "16:00")
      end
    end

    test "destroy touches schedule" do
      schedule = create_schedule!
      interval = schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      assert_changes -> { schedule.updated_at } do
        interval.destroy!
      end
    end

    test "create (shift interval) touches schedule" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")

      assert_changes -> { schedule.updated_at } do
        shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")
      end
    end

    test "update (shift interval) touches schedule" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")

      interval = shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")

      assert_changes -> { schedule.updated_at } do
        interval.update!(starts_at: "09:00", ends_at: "13:00")
      end
    end

    test "rejects overlapping intervals" do
      schedule = create_schedule!
      schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      interval = schedule.intervals.build(weekday: "mon", starts_at: "10:00", ends_at: "18:00")

      refute interval.valid?
      assert_includes interval.errors[:base], "hours cannot overlap"
    end

    test "schedule intervals require weekday" do
      schedule = create_schedule!
      interval = schedule.intervals.build(starts_at: "09:00", ends_at: "17:00")

      refute interval.valid?
      assert_includes interval.errors[:weekday], "can't be blank"
    end

    test "day intervals reject weekday" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")
      interval = shift.intervals.build(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      refute interval.valid?
      assert_includes interval.errors[:weekday], "must be blank"
    end
  end
end
