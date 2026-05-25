# frozen_string_literal: true

require "test_helper"

class BizRecord::ConfigurationBundleTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "touch rebuilds configuration from associations" do
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
end
