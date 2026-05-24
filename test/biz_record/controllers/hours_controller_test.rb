# frozen_string_literal: true

require "test_helper"
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "biz_record/engine"

module BizRecordHoursControllerTestApp
  class Application < Rails::Application
    config.root = File.expand_path("../../../tmp/hours_controller_app", __dir__)
    config.eager_load = false
    config.secret_key_base = "biz-record-test"
    config.hosts.clear
  end
end

BizRecordHoursControllerTestApp::Application.initialize!
BizRecordHoursControllerTestApp::Application.routes.draw do
  mount BizRecord::Engine, at: "/biz_record"
end

module BizRecord
  class HoursControllerTest < ActionDispatch::IntegrationTest
    self.app = BizRecordHoursControllerTestApp::Application

    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_show_links_to_add_edit_and_remove_hours
      schedule = create_schedule!

      get "/biz_record/schedules/#{schedule.id}"

      assert_response :success
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/mon/hours/09:00/edit']", "Edit"
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/mon/hours/09:00'][data-turbo-method='delete']", "Remove"
      assert_select "a[href='/biz_record/schedules/#{schedule.id}/mon/hours/new']", "Add hours"
    end

    def test_new_renders_hour_form
      schedule = create_schedule!

      get "/biz_record/schedules/#{schedule.id}/mon/hours/new"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/mon/hours'][method='post']"
      assert_select "select[name='hour[starts_at(4i)]']"
      assert_select "select[name='hour[starts_at(5i)]']"
      assert_select "select[name='hour[ends_at(4i)]']"
      assert_select "select[name='hour[ends_at(5i)]']"
    end

    def test_create_adds_hour_to_weekday
      schedule = create_schedule!

      post(
        "/biz_record/schedules/#{schedule.id}/sat/hours",
        params: {
          hour: {
            "starts_at(4i)" => "08",
            "starts_at(5i)" => "00",
            "ends_at(4i)" => "17",
            "ends_at(5i)" => "00"
          }
        }
      )

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
      assert_equal [["08:00", "17:00"]], schedule.reload.hours_for(:sat)
    end

    def test_edit_renders_existing_hour_form
      schedule = create_schedule!

      get "/biz_record/schedules/#{schedule.id}/mon/hours/09:00/edit"

      assert_response :success
      assert_select "form[action='/biz_record/schedules/#{schedule.id}/mon/hours/09:00'][method='post']"
      assert_select "select[name='hour[starts_at(4i)]'] option[selected][value='09']"
      assert_select "select[name='hour[starts_at(5i)]'] option[selected][value='00']"
      assert_select "select[name='hour[ends_at(4i)]'] option[selected][value='17']"
      assert_select "select[name='hour[ends_at(5i)]'] option[selected][value='00']"
    end

    def test_update_edits_existing_hour
      schedule = create_schedule!

      patch(
        "/biz_record/schedules/#{schedule.id}/mon/hours/09:00",
        params: {
          hour: {
            "starts_at(4i)" => "08",
            "starts_at(5i)" => "00",
            "ends_at(4i)" => "16",
            "ends_at(5i)" => "00"
          }
        }
      )

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
      assert_equal [["08:00", "16:00"]], schedule.reload.hours_for(:mon)
    end

    def test_destroy_removes_existing_hour
      schedule = create_schedule!

      delete "/biz_record/schedules/#{schedule.id}/mon/hours/09:00"

      assert_redirected_to "/biz_record/schedules/#{schedule.id}"
      assert_equal [], schedule.reload.hours_for(:mon)
    end
  end
end
