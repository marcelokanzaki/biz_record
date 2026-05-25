# frozen_string_literal: true

require "test_helper"

class BizRecord::BizScheduleTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "#to_biz_schedule" do
    schedule = create_schedule!

    schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")
    schedule.holiday_days.create!(date: "2026-05-25")

    biz_schedule = schedule.reload.to_biz_schedule

    assert biz_schedule.in_hours?(Time.utc(2026, 5, 18, 10))
    assert biz_schedule.on_holiday?(Time.utc(2026, 5, 25, 10))
  end
end
