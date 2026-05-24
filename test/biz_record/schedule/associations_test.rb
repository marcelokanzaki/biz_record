# frozen_string_literal: true

require "test_helper"

module BizRecord
  class ScheduleAssociationsTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_touch_rebuilds_configuration_from_associations
      schedule = create_schedule!

      schedule.intervals.create!(weekday: "mon", starts_at: "13:00", ends_at: "17:00")
      schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "12:00")

      shift = schedule.shift_days.create!(date: "2026-06-01")
      shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")

      break_day = schedule.break_days.create!(date: "2026-06-01")
      break_day.intervals.create!(starts_at: "12:00", ends_at: "13:00")

      schedule.holiday_days.create!(date: "2026-12-25")

      assert_equal(
        {
          "hours" => {
            "mon" => {
              "09:00" => "12:00",
              "13:00" => "17:00"
            }
          },
          "shifts" => {
            "2026-06-01" => {
              "10:00" => "14:00"
            }
          },
          "breaks" => {
            "2026-06-01" => {
              "12:00" => "13:00"
            }
          },
          "holidays" => ["2026-12-25"]
        },
        schedule.reload.configuration
      )
    end

    def test_to_biz_schedule_uses_rebuilt_configuration
      schedule = create_schedule!

      schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")
      schedule.holiday_days.create!(date: "2026-05-25")

      biz_schedule = schedule.reload.to_biz_schedule

      assert biz_schedule.in_hours?(Time.utc(2026, 5, 18, 10))
      assert biz_schedule.on_holiday?(Time.utc(2026, 5, 25, 10))
    end

    def test_old_configuration_mutation_api_is_not_exposed
      schedule = build_schedule

      refute_respond_to schedule, :replace_configuration
      refute_respond_to schedule, :add_hours
      refute_respond_to schedule, :add_shift
      refute_respond_to schedule, :add_break
      refute_respond_to schedule, :add_holiday
    end
  end
end
