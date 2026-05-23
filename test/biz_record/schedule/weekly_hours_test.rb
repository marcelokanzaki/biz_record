# frozen_string_literal: true

require "test_helper"

module BizRecord
  class WeeklyHoursTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_returns_hours_for_a_weekday
      schedule = Schedule.new(
        configuration: {
          hours: {
            mon: {
              "13:00" => "17:00",
              "09:00" => "12:00"
            }
          }
        }
      )

      assert_equal [["09:00", "12:00"], ["13:00", "17:00"]], schedule.hours_for(:mon)
    end

    def test_adds_hours_to_a_weekday
      schedule = build_schedule(configuration: { hours: {} })

      schedule.add_hours(:mon, "9:00", "12:00")
      schedule.add_hours("mon", "13:00", "17:00")

      assert_equal(
        {
          "hours" => {
            "mon" => {
              "09:00" => "12:00",
              "13:00" => "17:00"
            }
          },
          "shifts" => {},
          "breaks" => {},
          "holidays" => []
        },
        schedule.configuration
      )
      assert schedule.valid?
    end

    def test_replaces_hours_for_a_weekday
      schedule = Schedule.new

      schedule.replace_hours(:mon, [["8:00", "12:00"], ["14:00", "18:00"]])

      assert_equal [["08:00", "12:00"], ["14:00", "18:00"]], schedule.hours_for(:mon)
      assert_equal({ "08:00" => "12:00", "14:00" => "18:00" }, schedule.hours.fetch("mon"))
    end

    def test_replaces_hours_from_a_hash
      schedule = Schedule.new

      schedule.replace_hours(:sat, "10:00" => "14:00")

      assert_equal [["10:00", "14:00"]], schedule.hours_for(:sat)
    end

    def test_removes_a_matching_hour_range
      schedule = Schedule.new(
        configuration: {
          hours: {
            mon: {
              "09:00" => "12:00",
              "13:00" => "17:00"
            }
          }
        }
      )

      schedule.remove_hours(:mon, "09:00", "12:00")

      assert_equal [["13:00", "17:00"]], schedule.hours_for(:mon)
    end

    def test_clears_hours_for_a_weekday
      schedule = Schedule.new

      schedule.clear_hours(:mon)

      assert_equal [], schedule.hours_for(:mon)
      refute schedule.hours.key?("mon")
    end

    def test_persists_edited_hours
      schedule = build_schedule(configuration: { hours: {} })

      schedule.add_hours(:mon, "09:00", "17:00")
      schedule.save!

      assert_equal [["09:00", "17:00"]], schedule.reload.hours_for(:mon)
      assert schedule.to_biz_schedule.in_hours?(Time.utc(2026, 5, 18, 10))
    end

    def test_rejects_overlapping_hours
      schedule = Schedule.new

      error = assert_raises(ArgumentError) do
        schedule.replace_hours(:mon, [["09:00", "12:00"], ["11:00", "17:00"]])
      end

      assert_equal "hours cannot overlap", error.message
    end

    def test_rejects_invalid_weekdays
      schedule = Schedule.new

      error = assert_raises(ArgumentError) { schedule.hours_for(:monday) }

      assert_match(/weekday must be one of:/, error.message)
    end

    def test_rejects_invalid_times
      schedule = Schedule.new

      assert_raises(ArgumentError) { schedule.add_hours(:mon, "25:00", "26:00") }
      assert_raises(ArgumentError) { schedule.add_hours(:mon, "17:00", "09:00") }
    end
  end
end
