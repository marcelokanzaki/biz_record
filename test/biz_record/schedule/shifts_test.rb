# frozen_string_literal: true

require "test_helper"

module BizRecord
  class ShiftsTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_returns_shifts_for_a_date
      schedule = Schedule.new(
        configuration: {
          shifts: {
            "2026-06-01" => {
              "15:00" => "18:00",
              "10:00" => "14:00"
            }
          }
        }
      )

      assert_equal [["10:00", "14:00"], ["15:00", "18:00"]], schedule.shifts_for("2026-06-01")
    end

    def test_adds_shifts_to_a_date
      schedule = build_schedule

      schedule.add_shift("2026-06-01", "10:00", "14:00")
      schedule.add_shift(Date.new(2026, 6, 1), "15:00", "18:00")

      assert_equal(
        {
          "10:00" => "14:00",
          "15:00" => "18:00"
        },
        schedule.shifts.fetch("2026-06-01")
      )
      assert schedule.valid?
    end

    def test_replaces_shifts_for_a_date
      schedule = Schedule.new(
        configuration: {
          shifts: {
            "2026-06-01" => {
              "10:00" => "14:00"
            }
          }
        }
      )

      schedule.replace_shifts("2026-06-01", [["9:00", "12:00"], ["13:00", "17:00"]])

      assert_equal [["09:00", "12:00"], ["13:00", "17:00"]], schedule.shifts_for("2026-06-01")
    end

    def test_replaces_shifts_from_a_hash
      schedule = Schedule.new

      schedule.replace_shifts("2026-06-01", "10:00" => "14:00")

      assert_equal [["10:00", "14:00"]], schedule.shifts_for("2026-06-01")
    end

    def test_removes_a_matching_shift_range
      schedule = Schedule.new(
        configuration: {
          shifts: {
            "2026-06-01" => {
              "10:00" => "14:00",
              "15:00" => "18:00"
            }
          }
        }
      )

      schedule.remove_shift("2026-06-01", "10:00", "14:00")

      assert_equal [["15:00", "18:00"]], schedule.shifts_for("2026-06-01")
    end

    def test_clears_shifts_for_a_date
      schedule = Schedule.new(
        configuration: {
          shifts: {
            "2026-06-01" => {
              "10:00" => "14:00"
            }
          }
        }
      )

      schedule.clear_shifts("2026-06-01")

      assert_equal [], schedule.shifts_for("2026-06-01")
      refute schedule.shifts.key?("2026-06-01")
    end

    def test_clears_all_shifts
      schedule = Schedule.new(
        configuration: {
          shifts: {
            "2026-06-01" => {
              "10:00" => "14:00"
            }
          }
        }
      )

      schedule.clear_all_shifts

      assert_equal({}, schedule.shifts)
    end

    def test_persists_edited_shifts
      schedule = build_schedule

      schedule.add_shift("2026-06-01", "10:00", "14:00")
      schedule.save!

      assert_equal [["10:00", "14:00"]], schedule.reload.shifts_for("2026-06-01")
      assert schedule.to_biz_schedule.in_hours?(Time.utc(2026, 6, 1, 10))
      refute schedule.to_biz_schedule.in_hours?(Time.utc(2026, 6, 1, 15))
    end

    def test_rejects_overlapping_shifts
      schedule = Schedule.new

      error = assert_raises(ArgumentError) do
        schedule.replace_shifts("2026-06-01", [["10:00", "14:00"], ["13:00", "18:00"]])
      end

      assert_equal "shifts cannot overlap", error.message
    end

    def test_rejects_invalid_dates
      schedule = Schedule.new

      error = assert_raises(ArgumentError) { schedule.shifts_for("not-a-date") }

      assert_equal "shift date must be a valid ISO 8601 date", error.message
    end

    def test_rejects_invalid_times
      schedule = Schedule.new

      assert_raises(ArgumentError) { schedule.add_shift("2026-06-01", "25:00", "26:00") }
      assert_raises(ArgumentError) { schedule.add_shift("2026-06-01", "17:00", "09:00") }
    end
  end
end
