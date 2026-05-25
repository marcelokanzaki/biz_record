# frozen_string_literal: true

require "test_helper"

class BizRecord::SchedulableTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "exposes the has biz schedule macro to active record models" do
    assert_respond_to Account, :has_biz_schedule
  end

  test "defines a default schedule association" do
    assert_nil account.biz_schedule

    schedule = account.create_biz_schedule!

    assert_equal BizRecord::Schedule::DEFAULT_KEY, schedule.key
    assert_equal account, schedule.schedulable
    assert_equal schedule, account.reload.biz_schedule
  end

  test "defines named schedule associations" do
    support_schedule = account.create_support_schedule!
    dev_schedule = account.create_dev_schedule!

    assert_equal "support", support_schedule.key
    assert_equal "dev", dev_schedule.key
    assert_equal support_schedule, account.reload.support_schedule
    assert_equal dev_schedule, account.dev_schedule
  end

  test "builds named schedules with their configured key" do
    schedule = account.build_support_schedule

    assert_equal "support", schedule.key
    assert_equal account, schedule.schedulable
  end

  test "keeps named associations separate" do
    default_schedule = account.create_biz_schedule!
    support_schedule = account.create_support_schedule!

    account.reload

    assert_equal default_schedule, account.biz_schedule
    assert_equal support_schedule, account.support_schedule
  end
end
