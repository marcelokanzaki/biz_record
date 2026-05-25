# frozen_string_literal: true

require "test_helper"

class BizRecord::ScheduleTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "defaults to a valid biz schedule" do
    schedule = create_schedule!

    assert_equal "default", schedule.key
    assert_equal "Etc/UTC", schedule.time_zone
    assert_instance_of Biz::Schedule, schedule.to_biz_schedule
    assert schedule.to_biz_schedule.in_hours?(Time.utc(2026, 5, 18, 10))
  end

  test "uses configured default hours" do
    BizRecord.configure do |config|
      config.default_hours = {
        sun: [["10:00", "14:00"]]
      }
    end

    schedule = create_schedule!

    assert_equal(
      {
        "sun" => [["10:00", "14:00"]]
      },
      schedule.hours
    )
    assert schedule.to_biz_schedule.in_hours?(Time.utc(2026, 5, 17, 11))
    refute schedule.to_biz_schedule.in_hours?(Time.utc(2026, 5, 18, 11))
  end

  test "can belong to a schedulable" do
    schedule = BizRecord::Schedule.create!(schedulable: account, key: "support")

    assert_equal account, schedule.schedulable
    assert_equal schedule, account.support_schedule
  end

  test "converts configuration to biz schedule" do
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

  test "requires a schedulable" do
    schedule = BizRecord::Schedule.new

    refute schedule.valid?
    assert schedule.errors[:schedulable].any?
  end

  test "requires key to be unique within schedulable" do
    create_schedule!(key: "support")
    duplicate = build_schedule(key: "support")

    refute duplicate.valid?
    assert duplicate.errors[:key].any?
  end

  test "allows same key for different schedulables" do
    create_schedule!(key: "support")
    other_account = Account.create!(name: "Other")
    schedule = BizRecord::Schedule.new(schedulable: other_account, key: "support")

    assert schedule.valid?
  end

  test "lets biz validate schedule configuration" do
    schedule = build_schedule(configuration: { hours: {} })

    assert schedule.valid?
    assert_raises(Biz::Error::Configuration) do
      schedule.to_biz_schedule
    end
  end
end
