require "test_helper"

class BizRecord::KeyTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "default key" do
    schedule = create_schedule!
    assert_equal "default", schedule.key
  end

  test "additional keys" do
    schedule = BizRecord::Schedule.create!(schedulable: account, key: "support")
    assert_equal schedule, account.support_schedule
  end

  test "key is required" do
    schedule = BizRecord::Schedule.new(key: nil)
    assert_not schedule.valid?
    assert schedule.errors.where(:key, :blank).any?
  end

  test "key has to be unique within schedulable" do
    create_schedule!(key: "support")
    duplicate = build_schedule(key: "support")

    refute duplicate.valid?
    assert duplicate.errors[:key].any?
  end
end
