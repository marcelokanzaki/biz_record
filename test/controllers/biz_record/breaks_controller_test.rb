require "test_helper"

module BizRecord
  class BreaksControllerTest < ActionDispatch::IntegrationTest
    setup do
      Schedule.delete_all
      Account.delete_all
    end

    test "new" do
      schedule = create_schedule!
      get biz_record.new_schedule_break_path(schedule)
      assert_response :success
    end

    test "create" do
      schedule = create_schedule!

      assert_difference -> { schedule.break_days.count }, +1 do
        post biz_record.schedule_breaks_path(schedule),
          params: {
            break: {
              date: "2026-06-01"
            }
          }
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "edit" do
      schedule = create_schedule!
      break_day = create_break!(schedule)

      get biz_record.edit_schedule_break_path(schedule, break_day)
      assert_response :success
    end

    test "update" do
      schedule = create_schedule!
      break_day = create_break!(schedule)
      new_date = Date.new(2026, 6, 2)

      assert_changes -> { break_day.reload.date }, to: new_date do
        patch biz_record.schedule_break_path(schedule, break_day),
          params: {
            break: {
              date: new_date
            }
          }
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "destroy removes existing break" do
      schedule = create_schedule!
      break_day = create_break!(schedule)

      assert_difference -> { schedule.break_days.count }, -1 do
        delete biz_record.schedule_break_path(schedule, break_day)
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    private

    def create_break!(schedule)
      schedule.break_days.create!(date: "2026-06-01").tap do |break_day|
        break_day.intervals.create!(starts_at: "10:00", ends_at: "14:00")
      end
    end
  end
end
