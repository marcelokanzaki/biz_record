require "test_helper"

class BizRecord::HasScheduleTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "exposes the has biz schedule macro to active record models" do
    assert_respond_to Account, :has_schedule
  end

  test "defines a default schedule association" do
    assert_nil account.schedule
    account.create_schedule!
    assert_equal BizRecord::Schedule::Key::DEFAULT_KEY, account.schedule.key
  end

  test "defines named schedule associations" do
    account.create_support_schedule!
    account.create_dev_schedule!

    assert_equal "support", account.support_schedule.key
    assert_equal "dev", account.dev_schedule.key
  end
end
