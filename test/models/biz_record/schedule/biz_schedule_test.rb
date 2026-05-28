require "test_helper"

class BizRecord::BizScheduleTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "#biz_schedule" do
    schedule = create_schedule!
    assert_instance_of Biz::Schedule, schedule.biz_schedule
  end

  test "#biz_schedule is memoized" do
    schedule = create_schedule!
    assert_same schedule.biz_schedule, schedule.biz_schedule
  end

  test "#reload_biz_schedule" do
    schedule = create_schedule!

    assert_changes -> { schedule.biz_schedule.object_id } do
      schedule.reload_biz_schedule
    end
  end

  test "#biz_schedule resets when weekly interval changes" do
    schedule = create_schedule!

    assert_changes -> { schedule.biz_schedule.object_id } do
      schedule.intervals.mon.first.update!(weekday: "sun", starts_at: "10:00", ends_at: "14:00")
    end
  end

  test "#biz_schedule resets when time zone changes" do
    schedule = create_schedule!

    assert_changes -> { schedule.biz_schedule.object_id } do
      schedule.time_zone = "America/Sao_Paulo"
    end
  end

  test "#biz_schedule resets when schedule is touched" do
    schedule = create_schedule!

    assert_changes -> { schedule.biz_schedule.object_id } do
      schedule.touch
    end
  end

  test "#biz_schedule resets when schedule is reloaded" do
    schedule = create_schedule!

    assert_changes -> { schedule.biz_schedule.object_id } do
      schedule.reload
    end
  end
end
