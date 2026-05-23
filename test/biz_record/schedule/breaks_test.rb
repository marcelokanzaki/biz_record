# frozen_string_literal: true

require "test_helper"

module BizRecord
  class BreaksTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_returns_breaks_for_a_date
      schedule = Schedule.new(
        configuration: {
          breaks: {
            "2026-06-01" => {
              "15:00" => "15:30",
              "12:00" => "13:00"
            }
          }
        }
      )

      assert_equal [["12:00", "13:00"], ["15:00", "15:30"]], schedule.breaks_for("2026-06-01")
    end

    def test_adds_breaks_to_a_date
      schedule = build_schedule

      schedule.add_break("2026-06-01", "12:00", "13:00")
      schedule.add_break(Date.new(2026, 6, 1), "15:00", "15:30")

      assert_equal(
        {
          "12:00" => "13:00",
          "15:00" => "15:30"
        },
        schedule.breaks.fetch("2026-06-01")
      )
      assert schedule.valid?
    end

    def test_replaces_breaks_for_a_date
      schedule = Schedule.new(
        configuration: {
          breaks: {
            "2026-06-01" => {
              "12:00" => "13:00"
            }
          }
        }
      )

      schedule.replace_breaks("2026-06-01", [["11:00", "11:15"], ["15:00", "15:30"]])

      assert_equal [["11:00", "11:15"], ["15:00", "15:30"]], schedule.breaks_for("2026-06-01")
    end

    def test_replaces_breaks_from_a_hash
      schedule = Schedule.new

      schedule.replace_breaks("2026-06-01", "12:00" => "13:00")

      assert_equal [["12:00", "13:00"]], schedule.breaks_for("2026-06-01")
    end

    def test_removes_a_matching_break_range
      schedule = Schedule.new(
        configuration: {
          breaks: {
            "2026-06-01" => {
              "12:00" => "13:00",
              "15:00" => "15:30"
            }
          }
        }
      )

      schedule.remove_break("2026-06-01", "12:00", "13:00")

      assert_equal [["15:00", "15:30"]], schedule.breaks_for("2026-06-01")
    end

    def test_clears_breaks_for_a_date
      schedule = Schedule.new(
        configuration: {
          breaks: {
            "2026-06-01" => {
              "12:00" => "13:00"
            }
          }
        }
      )

      schedule.clear_breaks("2026-06-01")

      assert_equal [], schedule.breaks_for("2026-06-01")
      refute schedule.breaks.key?("2026-06-01")
    end

    def test_clears_all_breaks
      schedule = Schedule.new(
        configuration: {
          breaks: {
            "2026-06-01" => {
              "12:00" => "13:00"
            }
          }
        }
      )

      schedule.clear_all_breaks

      assert_equal({}, schedule.breaks)
    end

    def test_persists_edited_breaks
      schedule = build_schedule

      schedule.add_break("2026-06-01", "12:00", "13:00")
      schedule.save!

      assert_equal [["12:00", "13:00"]], schedule.reload.breaks_for("2026-06-01")
      assert schedule.to_biz_schedule.on_break?(Time.utc(2026, 6, 1, 12, 30))
      refute schedule.to_biz_schedule.in_hours?(Time.utc(2026, 6, 1, 12, 30))
    end

    def test_rejects_overlapping_breaks
      schedule = Schedule.new

      error = assert_raises(ArgumentError) do
        schedule.replace_breaks("2026-06-01", [["12:00", "13:00"], ["12:30", "13:30"]])
      end

      assert_equal "breaks cannot overlap", error.message
    end

    def test_rejects_invalid_dates
      schedule = Schedule.new

      error = assert_raises(ArgumentError) { schedule.breaks_for("not-a-date") }

      assert_equal "break date must be a valid ISO 8601 date", error.message
    end

    def test_rejects_invalid_times
      schedule = Schedule.new

      assert_raises(ArgumentError) { schedule.add_break("2026-06-01", "25:00", "26:00") }
      assert_raises(ArgumentError) { schedule.add_break("2026-06-01", "13:00", "12:00") }
    end
  end
end
