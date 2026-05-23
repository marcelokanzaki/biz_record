# frozen_string_literal: true

require "test_helper"

module BizRecord
  class ScheduleTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_defaults_to_a_valid_biz_schedule
      schedule = create_schedule!

      assert_equal "default", schedule.key
      assert_equal "Etc/UTC", schedule.time_zone
      assert_instance_of Biz::Schedule, schedule.to_biz_schedule
      assert schedule.to_biz_schedule.in_hours?(Time.utc(2026, 5, 18, 10))
    end

    def test_can_belong_to_a_schedulable
      schedule = Schedule.create!(schedulable: account, key: "support")

      assert_equal account, schedule.schedulable
      assert_equal schedule, account.support_schedule
    end

    def test_converts_configuration_to_biz_schedule
      schedule = create_schedule!(
        key: "support",
        time_zone: "America/Sao_Paulo",
        configuration: {
          hours: {
            mon: { "09:00" => "17:00" }
          },
          holidays: ["2026-05-25"]
        }
      )

      biz_schedule = schedule.to_biz_schedule

      assert biz_schedule.in_hours?(Time.utc(2026, 5, 18, 13))
      refute biz_schedule.in_hours?(Time.utc(2026, 5, 18, 21))
      assert biz_schedule.on_holiday?(Time.utc(2026, 5, 25, 13))
    end

    def test_requires_valid_time_zone
      schedule = Schedule.new(time_zone: "Mars/Base")

      refute schedule.valid?
      assert_includes schedule.errors[:time_zone], "is not a valid IANA time zone"
    end

    def test_requires_a_schedulable
      schedule = Schedule.new

      refute schedule.valid?
      assert schedule.errors[:schedulable].any?
    end

    def test_requires_key_to_be_unique_within_schedulable
      create_schedule!(key: "support")
      duplicate = build_schedule(key: "support")

      refute duplicate.valid?
      assert duplicate.errors[:key].any?
    end

    def test_allows_same_key_for_different_schedulables
      create_schedule!(key: "support")
      other_account = Account.create!(name: "Other")
      schedule = Schedule.new(schedulable: other_account, key: "support")

      assert schedule.valid?
    end

    def test_requires_configuration_that_biz_can_use
      schedule = Schedule.new(configuration: { hours: {} })

      refute schedule.valid?
      assert schedule.errors[:configuration].any?
    end
  end
end
