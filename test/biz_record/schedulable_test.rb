# frozen_string_literal: true

require "test_helper"

module BizRecord
  class SchedulableTest < Minitest::Test
    def setup
      Schedule.delete_all
      Account.delete_all
    end

    def test_exposes_the_has_biz_schedule_macro_to_active_record_models
      assert_respond_to Account, :has_biz_schedule
    end

    def test_defines_a_default_schedule_association
      assert_nil account.biz_schedule

      schedule = account.create_biz_schedule!

      assert_equal Schedule::DEFAULT_KEY, schedule.key
      assert_equal account, schedule.schedulable
      assert_equal schedule, account.reload.biz_schedule
    end

    def test_defines_named_schedule_associations
      support_schedule = account.create_support_schedule!
      dev_schedule = account.create_dev_schedule!

      assert_equal "support", support_schedule.key
      assert_equal "dev", dev_schedule.key
      assert_equal support_schedule, account.reload.support_schedule
      assert_equal dev_schedule, account.dev_schedule
    end

    def test_builds_named_schedules_with_their_configured_key
      schedule = account.build_support_schedule

      assert_equal "support", schedule.key
      assert_equal account, schedule.schedulable
    end

    def test_keeps_named_associations_separate
      default_schedule = account.create_biz_schedule!
      support_schedule = account.create_support_schedule!

      account.reload

      assert_equal default_schedule, account.biz_schedule
      assert_equal support_schedule, account.support_schedule
    end
  end
end
