# frozen_string_literal: true

require "test_helper"

module BizRecord
  class IntervalsControllerTest < ActionDispatch::IntegrationTest
    setup do
      Schedule.delete_all
      Account.delete_all
    end

    test "show links to add edit and remove intervals" do
      schedule = create_schedule!
      interval = schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      get "/biz_record/schedules/#{schedule.id}"

      assert_response :success
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}/edit']", "Edit"
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}'][data-turbo-method='delete']", "Remove"
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/mon/intervals/new']", "Add hours"
    end

    test "new renders interval form" do
      schedule = create_schedule!

      get "/biz_record/schedules/#{schedule.id}/mon/intervals/new"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/mon/intervals'][method='post']"
      assert_select "select[name='interval[starts_at(4i)]']"
      assert_select "select[name='interval[starts_at(5i)]']"
      assert_select "select[name='interval[ends_at(4i)]']"
      assert_select "select[name='interval[ends_at(5i)]']"
    end

    test "create adds interval to weekday" do
      schedule = create_schedule!

      post(
        "/biz_record/schedules/#{schedule.id}/sat/intervals",
        params: {
          interval: {
            "starts_at(4i)" => "08",
            "starts_at(5i)" => "00",
            "ends_at(4i)" => "17",
            "ends_at(5i)" => "00"
          }
        }
      )

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
    end

    test "edit renders existing interval form" do
      schedule = create_schedule!
      interval = schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      get "/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}/edit"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}'][method='post']"
      assert_select "select[name='interval[starts_at(4i)]'] option[selected][value='09']"
      assert_select "select[name='interval[starts_at(5i)]'] option[selected][value='00']"
      assert_select "select[name='interval[ends_at(4i)]'] option[selected][value='17']"
      assert_select "select[name='interval[ends_at(5i)]'] option[selected][value='00']"
    end

    test "update edits existing interval" do
      schedule = create_schedule!
      interval = schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      patch(
        "/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}",
        params: {
          interval: {
            "starts_at(4i)" => "08",
            "starts_at(5i)" => "00",
            "ends_at(4i)" => "16",
            "ends_at(5i)" => "00"
          }
        }
      )

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
    end

    test "destroy removes existing interval" do
      schedule = create_schedule!
      interval = schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

      delete "/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}"

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
    end

    test "new renders shift interval form" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")

      get "/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/intervals/new"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/intervals'][method='post']"
      assert_select "select[name='interval[starts_at(4i)]']"
      assert_select "select[name='interval[starts_at(5i)]']"
      assert_select "select[name='interval[ends_at(4i)]']"
      assert_select "select[name='interval[ends_at(5i)]']"
    end

    test "create adds interval to shift" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")

      post(
        "/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/intervals",
        params: {
          interval: {
            "starts_at(4i)" => "10",
            "starts_at(5i)" => "00",
            "ends_at(4i)" => "14",
            "ends_at(5i)" => "00"
          }
        }
      )

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
    end

    test "edit renders shift interval form" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")
      interval = shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")

      get "/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/intervals/#{interval.id}/edit"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/intervals/#{interval.id}'][method='post']"
      assert_select "select[name='interval[starts_at(4i)]'] option[selected][value='10']"
      assert_select "select[name='interval[starts_at(5i)]'] option[selected][value='00']"
      assert_select "select[name='interval[ends_at(4i)]'] option[selected][value='14']"
      assert_select "select[name='interval[ends_at(5i)]'] option[selected][value='00']"
    end

    test "update edits shift interval" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")
      interval = shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")

      patch(
        "/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/intervals/#{interval.id}",
        params: {
          interval: {
            "starts_at(4i)" => "09",
            "starts_at(5i)" => "00",
            "ends_at(4i)" => "13",
            "ends_at(5i)" => "00"
          }
        }
      )

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
    end

    test "destroy removes shift interval" do
      schedule = create_schedule!
      shift = schedule.shift_days.create!(date: "2026-06-01")
      interval = shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")

      delete "/biz_record/schedules/#{schedule.id}/shifts/#{shift.id}/intervals/#{interval.id}"

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
    end
  end
end
