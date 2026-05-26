require "test_helper"

class BizRecord::BizScheduleTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "#biz_schedule" do
    schedule = create_schedule!

    schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")
    break_day = schedule.break_days.create!(date: "2026-05-18")
    break_day.intervals.create!(starts_at: "12:00", ends_at: "13:00")
    schedule.holiday_days.create!(date: "2026-05-25")

    biz_schedule = schedule.reload.biz_schedule

    assert biz_schedule.in_hours?(Time.utc(2026, 5, 18, 10))
    assert biz_schedule.on_break?(Time.utc(2026, 5, 18, 12, 30))
    refute biz_schedule.in_hours?(Time.utc(2026, 5, 18, 12, 30))
    assert biz_schedule.on_holiday?(Time.utc(2026, 5, 25, 10))
  end

  test "#biz_schedule is memoized" do
    schedule = create_schedule!

    assert_same schedule.biz_schedule, schedule.biz_schedule
  end

  test "#reload_biz_schedule rebuilds biz_schedule" do
    schedule = create_schedule!
    biz_schedule = schedule.biz_schedule

    reloaded_biz_schedule = schedule.reload_biz_schedule

    refute_same biz_schedule, reloaded_biz_schedule
    assert_same reloaded_biz_schedule, schedule.biz_schedule
  end

  test "#biz_schedule is reset when configuration changes" do
    schedule = create_schedule!
    biz_schedule = schedule.biz_schedule

    schedule.configuration = {
      hours: {
        sun: { "10:00" => "14:00" }
      }
    }

    refute_same biz_schedule, schedule.biz_schedule
    assert schedule.in_hours?(Time.utc(2026, 5, 17, 11))
  end

  test "#biz_schedule is reset when time zone changes" do
    schedule = create_schedule!(
      configuration: {
        hours: {
          mon: { "09:00" => "10:00" }
        }
      }
    )
    biz_schedule = schedule.biz_schedule

    schedule.time_zone = "America/Sao_Paulo"

    refute_same biz_schedule, schedule.biz_schedule
    refute schedule.in_hours?(Time.utc(2026, 5, 18, 9, 30))
  end

  test "#biz_schedule is reset when schedule is touched" do
    schedule = create_schedule!
    biz_schedule = schedule.biz_schedule

    schedule.intervals.create!(weekday: "mon", starts_at: "10:00", ends_at: "11:00")

    refute_same biz_schedule, schedule.biz_schedule
    assert schedule.in_hours?(Time.utc(2026, 5, 18, 10, 30))
    refute schedule.in_hours?(Time.utc(2026, 5, 18, 16))
  end

  test "#biz_schedule is reset when schedule is reloaded" do
    schedule = create_schedule!
    biz_schedule = schedule.biz_schedule

    BizRecord::Schedule.find(schedule.id).update!(
      configuration: {
        hours: {
          sun: { "10:00" => "14:00" }
        }
      }
    )

    schedule.reload

    refute_same biz_schedule, schedule.biz_schedule
    assert schedule.in_hours?(Time.utc(2026, 5, 17, 11))
  end
end
