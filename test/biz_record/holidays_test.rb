# frozen_string_literal: true

require "test_helper"

module BizRecord
  class HolidaysTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_adds_holidays
      schedule = Schedule.new

      schedule.add_holiday("2026-12-25")
      schedule.add_holiday(Date.new(2026, 1, 1))

      assert_equal ["2026-01-01", "2026-12-25"], schedule.holidays
      assert schedule.valid?
    end

    def test_replaces_holidays
      schedule = Schedule.new(configuration: { holidays: ["2026-12-25"] })

      schedule.replace_holidays(["2026-05-01", Date.new(2026, 1, 1)])

      assert_equal ["2026-01-01", "2026-05-01"], schedule.holidays
    end

    def test_deduplicates_holidays
      schedule = Schedule.new

      schedule.replace_holidays(["2026-01-01", Date.new(2026, 1, 1), "2026-01-01"])

      assert_equal ["2026-01-01"], schedule.holidays
    end

    def test_removes_holidays
      schedule = Schedule.new(configuration: { holidays: ["2026-01-01", "2026-12-25"] })

      schedule.remove_holiday(Date.new(2026, 1, 1))

      assert_equal ["2026-12-25"], schedule.holidays
    end

    def test_clears_holidays
      schedule = Schedule.new(configuration: { holidays: ["2026-01-01"] })

      schedule.clear_holidays

      assert_equal [], schedule.holidays
    end

    def test_checks_holidays
      schedule = Schedule.new(configuration: { holidays: ["2026-01-01"] })

      assert schedule.holiday?("2026-01-01")
      refute schedule.holiday?("2026-01-02")
    end

    def test_accepts_time_like_holidays
      schedule = Schedule.new

      schedule.add_holiday(Time.utc(2026, 12, 25, 10))

      assert_equal ["2026-12-25"], schedule.holidays
    end

    def test_persists_edited_holidays
      schedule = Schedule.create!

      schedule.add_holiday("2026-12-25")
      schedule.save!

      assert_equal ["2026-12-25"], schedule.reload.holidays
      assert schedule.to_biz_schedule.on_holiday?(Time.utc(2026, 12, 25, 10))
    end

    def test_rejects_invalid_holidays
      schedule = Schedule.new

      error = assert_raises(ArgumentError) { schedule.add_holiday("not-a-date") }

      assert_equal "holiday must be a valid ISO 8601 date", error.message
    end
  end
end
