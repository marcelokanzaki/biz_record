# frozen_string_literal: true

require "test_helper"
require_relative "test_app"

module BizRecord
  class ShiftsControllerTest < ActionDispatch::IntegrationTest
    self.app = BizRecordControllerTestApp::Application

    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_show_links_to_add_edit_and_remove_shifts
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

    def test_new_renders_shift_form_without_interval_fields
      schedule = create_schedule!

      get "/biz_record/schedules/#{schedule.id}/shifts/new"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/shifts'][method='post']"
      assert_select "input[name='shift[date]'][type='date']"
      assert_select "select[name^='shift[intervals_attributes]']", false
    end

    def test_create_adds_shift_without_schedule_shift_hours
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
      assert_equal [], schedule.reload.shifts_for("2026-06-01")
      assert_equal Date.new(2026, 6, 1), schedule.shift_days.first.date
      assert_empty schedule.shift_days.first.intervals
    end

    def test_edit_renders_existing_shift_form_without_interval_fields
      schedule = create_schedule!
      shift = create_shift!(schedule)

      get "/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/edit"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}'][method='post']"
      assert_select "input[name='shift[date]'][value='2026-06-01']"
      assert_select "select[name^='shift[intervals_attributes]']", false
    end

    def test_update_edits_existing_shift_date
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
      assert_equal [], schedule.reload.shifts_for("2026-06-01")
      assert_equal [["10:00", "14:00"]], schedule.shifts_for("2026-06-02")
      assert_equal Date.new(2026, 6, 2), shift.reload.date
    end

    def test_destroy_removes_existing_shift
      schedule = create_schedule!
      shift = create_shift!(schedule)

      delete "/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}"

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
      assert_equal [], schedule.reload.shifts_for("2026-06-01")
      assert_empty schedule.shift_days
    end

    private

    def create_shift!(schedule)
      schedule.shift_days.create!(date: "2026-06-01").tap do |shift|
        shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")
      end
    end
  end
end
