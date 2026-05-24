# frozen_string_literal: true

require "test_helper"

module BizRecord
  class DayShiftTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_schedule_creates_shift_days_from_configuration
      schedule = create_schedule!(
        configuration: {
          shifts: {
            "2026-06-01" => {
              "10:00" => "14:00"
            }
          }
        }
      )

      shift = schedule.shift_days.first

      assert_equal Date.new(2026, 6, 1), shift.date
      assert_equal [["10:00", "14:00"]], shift.intervals.map(&:formatted_times)
    end

    def test_creating_shift_does_not_create_schedule_shifts_without_intervals
      schedule = create_schedule!

      schedule.shift_days.create!(date: "2026-06-01")

      assert_equal [], schedule.reload.shifts_for("2026-06-01")
    end

    def test_creating_shift_interval_syncs_schedule_shifts
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")

      shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")

      assert_equal [["10:00", "14:00"]], schedule.reload.shifts_for("2026-06-01")
    end

    def test_updating_shift_interval_syncs_schedule_shifts
      schedule = create_schedule!
      shift = create_shift!(schedule)
      interval = shift.intervals.first

      interval.update!(starts_at: "09:00", ends_at: "13:00")

      assert_equal [["09:00", "13:00"]], schedule.reload.shifts_for("2026-06-01")
    end

    def test_updating_shift_date_moves_schedule_shifts
      schedule = create_schedule!
      shift = create_shift!(schedule)

      shift.update!(date: "2026-06-02")

      assert_equal [], schedule.reload.shifts_for("2026-06-01")
      assert_equal [["10:00", "14:00"]], schedule.shifts_for("2026-06-02")
    end

    def test_destroying_shift_clears_schedule_shifts
      schedule = create_schedule!
      shift = create_shift!(schedule)

      shift.destroy!

      assert_equal [], schedule.reload.shifts_for("2026-06-01")
    end

    def test_allows_shift_without_intervals
      schedule = create_schedule!
      shift = schedule.shift_days.build(date: "2026-06-01")

      assert shift.valid?
    end

    private

    def create_shift!(schedule)
      schedule.shift_days.create!(date: "2026-06-01").tap do |shift|
        shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")
      end
    end
  end
end
