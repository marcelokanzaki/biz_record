# frozen_string_literal: true

require "test_helper"

module BizRecord
  class ShiftsControllerTest < ActionDispatch::IntegrationTest
    setup do
      Schedule.delete_all
      Account.delete_all
    end

    test "show links to add edit and remove shifts" do
      schedule = create_schedule!
      shift = create_shift!(schedule)

      get "/biz_record/schedules/#{schedule.id}"

      assert_response :success
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/shifts/new']", "Add shift"
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/edit']", "Edit"
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}'][data-turbo-method='delete']", "Remove"
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/intervals/new']", "Add hours"

      interval = shift.intervals.first

      assert_select "a[href='/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/intervals/#{interval.id}/edit']", "Edit"
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/intervals/#{interval.id}'][data-turbo-method='delete']", "Remove"
    end

    test "new renders shift form without interval fields" do
      schedule = create_schedule!

      get "/biz_record/schedules/#{schedule.id}/shifts/new"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/shifts'][method='post']"
      assert_select "input[name='shift[date]'][type='date']"
      assert_select "select[name^='shift[intervals_attributes]']", false
    end

    test "create adds shift without schedule shift hours" do
      schedule = create_schedule!

      post(
        "/biz_record/schedules/#{schedule.id}/shifts",
        params: {
          shift: {
            date: "2026-06-01"
          }
        }
      )

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
    end

    test "edit renders existing shift form without interval fields" do
      schedule = create_schedule!
      shift = create_shift!(schedule)

      get "/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/edit"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}'][method='post']"
      assert_select "input[name='shift[date]'][value='2026-06-01']"
      assert_select "select[name^='shift[intervals_attributes]']", false
    end

    test "update edits existing shift date" do
      schedule = create_schedule!
      shift = create_shift!(schedule)

      patch(
        "/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}",
        params: {
          shift: {
            date: "2026-06-02"
          }
        }
      )

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
    end

    test "destroy removes existing shift" do
      schedule = create_schedule!
      shift = create_shift!(schedule)

      delete "/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}"

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
    end

    private

    def create_shift!(schedule)
      schedule.shift_days.create!(date: "2026-06-01").tap do |shift|
        shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")
      end
    end
  end
end
