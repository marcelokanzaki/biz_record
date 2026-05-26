require "test_helper"

module BizRecord
  class ShiftsControllerTest < ActionDispatch::IntegrationTest
    setup do
      Schedule.delete_all
      Account.delete_all
    end

    test "new" do
      schedule = create_schedule!
      get biz_record.new_schedule_shift_path(schedule)
      assert_response :success
    end

    test "create" do
      schedule = create_schedule!

      assert_difference -> { schedule.shift_days.count }, +1 do
        post biz_record.schedule_shifts_path(schedule),
          params: {
            shift: {
              date: "2026-06-01"
            }
          }
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "edit" do
      schedule = create_schedule!
      shift = create_shift!(schedule)

      get biz_record.edit_schedule_shift_path(schedule, shift)
      assert_response :success
    end

    test "update" do
      schedule = create_schedule!
      shift = create_shift!(schedule)
      new_date = Date.new(2026, 6, 2)

      assert_changes -> { shift.reload.date }, to: new_date do
        patch biz_record.schedule_shift_path(schedule, shift),
          params: {
            shift: {
              date: new_date
            }
          }
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    test "destroy removes existing shift" do
      schedule = create_schedule!
      shift = create_shift!(schedule)

      assert_difference -> { schedule.shift_days.count }, -1 do
        delete biz_record.schedule_shift_path(schedule, shift)
      end

      assert_redirected_to biz_record.schedule_path(schedule)
    end

    private

    def create_shift!(schedule)
      schedule.shift_days.create!(date: "2026-06-01").tap do |shift|
        shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")
      end
    end
  end
end
