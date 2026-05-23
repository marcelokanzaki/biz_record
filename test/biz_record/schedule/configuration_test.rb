# frozen_string_literal: true

require "test_helper"

module BizRecord
  class ScheduleConfigurationTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_returns_a_json_ready_schedule_configuration
      schedule = Schedule.new(
        configuration: {
          hours: {
            mon: {
              "09:00" => "17:00"
            }
          },
          shifts: {
            "2026-06-01" => {
              "10:00" => "14:00"
            }
          },
          breaks: {
            "2026-06-01" => {
              "12:00" => "13:00"
            }
          },
          holidays: ["2026-12-25"]
        }
      )

      assert_equal(
        {
          "hours" => {
            "mon" => {
              "09:00" => "17:00"
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
        schedule.to_biz_configuration
      )
    end

    def test_replaces_and_normalizes_the_full_configuration
      schedule = build_schedule

      schedule.replace_configuration(
        hours: {
          mon: [
            ["13:00", "17:00"],
            ["9:00", "12:00"]
          ]
        },
        shifts: {
          Date.new(2026, 6, 1) => {
            "10:00" => "14:00"
          }
        },
        breaks: {
          "2026-06-01" => [
            ["12:00", "13:00"]
          ]
        },
        holidays: [
          "2026-12-25",
          Date.new(2026, 1, 1),
          "2026-12-25"
        ]
      )

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
          "holidays" => ["2026-01-01", "2026-12-25"]
        },
        schedule.configuration
      )
      assert schedule.valid?
    end

    def test_replaces_missing_sections_with_defaults
      schedule = Schedule.new(
        configuration: {
          hours: {
            sun: {
              "10:00" => "14:00"
            }
          },
          shifts: {
            "2026-06-01" => {
              "10:00" => "14:00"
            }
          },
          breaks: {
            "2026-06-01" => {
              "12:00" => "13:00"
            }
          },
          holidays: ["2026-12-25"]
        }
      )

      schedule.replace_configuration(holidays: ["2026-01-01"])

      assert_equal Schedule::DEFAULT_HOURS, schedule.hours
      assert_equal({}, schedule.shifts)
      assert_equal({}, schedule.breaks)
      assert_equal ["2026-01-01"], schedule.holidays
    end

    def test_persists_replaced_configuration
      schedule = build_schedule

      schedule.replace_configuration(
        hours: {
          mon: {
            "09:00" => "17:00"
          }
        },
        holidays: ["2026-12-25"]
      )
      schedule.save!

      schedule.reload

      assert_equal [["09:00", "17:00"]], schedule.hours_for(:mon)
      assert schedule.to_biz_schedule.on_holiday?(Time.utc(2026, 12, 25, 10))
    end

    def test_rejects_unknown_configuration_keys
      schedule = Schedule.new

      error = assert_raises(ArgumentError) do
        schedule.replace_configuration(foo: {})
      end

      assert_equal "configuration contains unknown keys: foo", error.message
    end

    def test_rejects_non_hash_configuration
      schedule = Schedule.new

      error = assert_raises(ArgumentError) do
        schedule.replace_configuration("not-a-hash")
      end

      assert_equal "configuration must be a hash", error.message
    end

    def test_rejects_invalid_nested_values
      schedule = Schedule.new

      assert_raises(ArgumentError) do
        schedule.replace_configuration(hours: { mon: [["17:00", "09:00"]] })
      end

      assert_raises(ArgumentError) do
        schedule.replace_configuration(shifts: { "not-a-date" => [["09:00", "17:00"]] })
      end
    end
  end
end
