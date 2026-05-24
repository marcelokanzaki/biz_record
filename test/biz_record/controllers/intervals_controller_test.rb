# frozen_string_literal: true

require "test_helper"
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "biz_record/engine"

module BizRecordIntervalsControllerTestApp
  class Application < Rails::Application
    config.root = File.expand_path("../../../tmp/intervals_controller_app", __dir__)
    config.eager_load = false
    config.secret_key_base = "biz-record-test"
    config.hosts.clear
  end
end

BizRecordIntervalsControllerTestApp::Application.initialize!
BizRecordIntervalsControllerTestApp::Application.routes.draw do
  mount BizRecord::Engine, at: "/biz_record"
end

module BizRecord
  class IntervalsControllerTest < ActionDispatch::IntegrationTest
    self.app = BizRecordIntervalsControllerTestApp::Application

    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_show_links_to_add_edit_and_remove_intervals
      schedule = create_schedule!
      interval = schedule.intervals.mon.first

      get "/biz_record/schedules/#{schedule.id}"

      assert_response :success
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}/edit']", "Edit"
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}'][data-turbo-method='delete']", "Remove"
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/mon/intervals/new']", "Add hours"
    end

    def test_new_renders_interval_form
      schedule = create_schedule!

      get "/biz_record/schedules/#{schedule.id}/mon/intervals/new"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/mon/intervals'][method='post']"
      assert_select "select[name='interval[starts_at(4i)]']"
      assert_select "select[name='interval[starts_at(5i)]']"
      assert_select "select[name='interval[ends_at(4i)]']"
      assert_select "select[name='interval[ends_at(5i)]']"
    end

    def test_create_adds_interval_to_weekday
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
      assert_equal [["08:00", "17:00"]], schedule.reload.hours_for(:sat)
      assert_equal [["08:00", "17:00"]], schedule.intervals.sat.map(&:formatted_times)
    end

    def test_edit_renders_existing_interval_form
      schedule = create_schedule!
      interval = schedule.intervals.mon.first

      get "/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}/edit"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}'][method='post']"
      assert_select "select[name='interval[starts_at(4i)]'] option[selected][value='09']"
      assert_select "select[name='interval[starts_at(5i)]'] option[selected][value='00']"
      assert_select "select[name='interval[ends_at(4i)]'] option[selected][value='17']"
      assert_select "select[name='interval[ends_at(5i)]'] option[selected][value='00']"
    end

    def test_update_edits_existing_interval
      schedule = create_schedule!
      interval = schedule.intervals.mon.first

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
      assert_equal [["08:00", "16:00"]], schedule.reload.hours_for(:mon)
      assert_equal [["08:00", "16:00"]], schedule.intervals.mon.map(&:formatted_times)
    end

    def test_destroy_removes_existing_interval
      schedule = create_schedule!
      interval = schedule.intervals.mon.first

      delete "/biz_record/schedules/#{schedule.id}/mon/intervals/#{interval.id}"

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
      assert_equal [], schedule.reload.hours_for(:mon)
      assert_empty schedule.intervals.mon
    end
  end
end
