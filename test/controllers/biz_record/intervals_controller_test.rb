require "test_helper"

module BizRecord
  class IntervalsControllerTest < ActionDispatch::IntegrationTest
    setup do
      Schedule.delete_all
      Account.delete_all
    end

    test "new (weekday)" do
      schedule = create_schedule!
      get biz_record.new_schedule_interval_path(schedule, weekday: :mon)
      assert_response :success
    end

    test "new (shift)" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")
      get biz_record.new_schedule_shift_interval_path(schedule, shift)
      assert_response :success
    end

    test "new (break)" do
      schedule = create_schedule!
      break_day = schedule.break_days.create!(date: "2026-06-01")
      get biz_record.new_schedule_break_interval_path(schedule, break_day)
      assert_response :success
    end

    test "create (weekday)" do
      schedule = create_schedule!

      assert_difference -> { schedule.intervals.sun.count }, +1 do
        post biz_record.schedule_intervals_path(schedule, weekday: :sun),
          params: {
            interval: {
              "starts_at(4i)" => "08",
              "starts_at(5i)" => "00",
              "ends_at(4i)"   => "17",
              "ends_at(5i)"   => "00"
            }
          }
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "create (shift)" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")

      assert_difference -> { shift.intervals.count }, +1 do
        post biz_record.schedule_shift_intervals_path(schedule, shift),
          params: {
            interval: {
              "starts_at(4i)" => "08",
              "starts_at(5i)" => "00",
              "ends_at(4i)"   => "17",
              "ends_at(5i)"   => "00"
            }
          }
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "create (break)" do
      schedule = create_schedule!
      break_day = schedule.break_days.create!(date: "2026-06-01")

      assert_difference -> { break_day.intervals.count }, +1 do
        post biz_record.schedule_break_intervals_path(schedule, break_day),
          params: {
            interval: {
              "starts_at(4i)" => "08",
              "starts_at(5i)" => "00",
              "ends_at(4i)"   => "17",
              "ends_at(5i)"   => "00"
            }
          }
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "edit (weekday)" do
      schedule = create_schedule!
      interval = schedule.intervals.mon.first

      get biz_record.edit_schedule_interval_path(schedule, interval, weekday: :mon)

      assert_response :success
    end

    test "edit (shift)" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")
      interval = shift.intervals.create!(starts_at: "08:00", ends_at: "17:00")

      get biz_record.edit_schedule_shift_interval_path(schedule, shift, interval)

      assert_response :success
    end

    test "edit (break)" do
      schedule = create_schedule!
      break_day = schedule.break_days.create!(date: "2026-06-01")
      interval = break_day.intervals.create!(starts_at: "08:00", ends_at: "17:00")

      get biz_record.edit_schedule_break_interval_path(schedule, break_day, interval)

      assert_response :success
    end

    test "update (weekday)" do
      schedule = create_schedule!
      interval = schedule.intervals.mon.first

      patch biz_record.schedule_interval_path(schedule, interval, weekday: :mon),
        params: {
          interval: {
            "starts_at(4i)" => "09",
            "starts_at(5i)" => "30",
            "ends_at(4i)"   => "18",
            "ends_at(5i)"   => "00"
          }
        }

      assert_redirected_to biz_record.schedule_path(schedule)

      interval.reload
      assert_equal "09:30", interval.starts_at.strftime("%H:%M")
      assert_equal "18:00", interval.ends_at.strftime("%H:%M")
    end

    test "update (shift)" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")
      interval = shift.intervals.create!(starts_at: "08:00", ends_at: "17:00")

      patch biz_record.schedule_shift_interval_path(schedule, shift, interval),
        params: {
          interval: {
            "starts_at(4i)" => "09",
            "starts_at(5i)" => "30",
            "ends_at(4i)"   => "18",
            "ends_at(5i)"   => "00"
          }
        }

      assert_redirected_to biz_record.schedule_path(schedule)

      interval.reload
      assert_equal "09:30", interval.starts_at.strftime("%H:%M")
      assert_equal "18:00", interval.ends_at.strftime("%H:%M")
    end

    test "update (break)" do
      schedule = create_schedule!
      break_day = schedule.break_days.create!(date: "2026-06-01")
      interval = break_day.intervals.create!(starts_at: "08:00", ends_at: "17:00")

      patch biz_record.schedule_break_interval_path(schedule, break_day, interval),
        params: {
          interval: {
            "starts_at(4i)" => "09",
            "starts_at(5i)" => "30",
            "ends_at(4i)"   => "18",
            "ends_at(5i)"   => "00"
          }
        }

      assert_redirected_to biz_record.schedule_path(schedule)

      interval.reload
      assert_equal "09:30", interval.starts_at.strftime("%H:%M")
      assert_equal "18:00", interval.ends_at.strftime("%H:%M")
    end

    test "destroy (weekday)" do
      schedule = create_schedule!
      interval = schedule.intervals.mon.first

      assert_difference -> { schedule.intervals.count }, -1 do
        delete biz_record.schedule_interval_path(schedule, interval, weekday: :mon)
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "destroy (shift)" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")
      interval = shift.intervals.create!(starts_at: "08:00", ends_at: "17:00")

      assert_difference -> { shift.intervals.count }, -1 do
        delete biz_record.schedule_shift_interval_path(schedule, shift, interval)
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "destroy (break)" do
      schedule = create_schedule!
      break_day = schedule.break_days.create!(date: "2026-06-01")
      interval = break_day.intervals.create!(starts_at: "08:00", ends_at: "17:00")

      assert_difference -> { break_day.intervals.count }, -1 do
        delete biz_record.schedule_break_interval_path(schedule, break_day, interval)
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end
  end
end
