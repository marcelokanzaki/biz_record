require "test_helper"

module BizRecord
  class HolidaysControllerTest < ActionDispatch::IntegrationTest
    setup do
      Schedule.delete_all
      Account.delete_all
    end

    test "new" do
      schedule = create_schedule!
      get biz_record.new_schedule_holiday_path(schedule)
      assert_response :success
    end

    test "create" do
      schedule = create_schedule!

      assert_difference -> { schedule.holiday_days.count }, +1 do
        post biz_record.schedule_holidays_path(schedule),
          params: {
            holiday: {
              date: "2026-12-25"
            }
          }
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "edit" do
      schedule = create_schedule!
      holiday = create_holiday!(schedule)

      get biz_record.edit_schedule_holiday_path(schedule, holiday)
      assert_response :success
    end

    test "update" do
      schedule = create_schedule!
      holiday = create_holiday!(schedule)
      new_date = Date.new(2026, 1, 1)

      assert_changes -> { holiday.reload.date }, to: new_date do
        patch biz_record.schedule_holiday_path(schedule, holiday),
          params: {
            holiday: {
              date: new_date
            }
          }
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "destroy removes existing holiday" do
      schedule = create_schedule!
      holiday = create_holiday!(schedule)

      assert_difference -> { schedule.holiday_days.count }, -1 do
        delete biz_record.schedule_holiday_path(schedule, holiday)
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    private

    def create_holiday!(schedule)
      schedule.holiday_days.create!(date: "2026-12-25")
    end
  end
end
