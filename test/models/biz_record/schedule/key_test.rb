# frozen_string_literal: true

require "test_helper"

class BizRecord::KeyTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "defaults to default key" do
    schedule = create_schedule!
    assert_equal "default", schedule.key
  end

  test "requires key" do
    schedule = BizRecord::Schedule.new(key: nil)
    assert_not schedule.valid?
    assert schedule.errors.where(:key, :blank).any?
  end

  test "requires key to be unique within schedulable" do
    create_schedule!(key: "support")
    duplicate = build_schedule(key: "support")

    refute duplicate.valid?
    assert duplicate.errors[:key].any?
  end

  test "allows same key for different schedulables" do
    create_schedule!(key: "support")
    other_account = Account.create!(name: "Other")
    schedule = BizRecord::Schedule.new(schedulable: other_account, key: "support")

    assert schedule.valid?
  end
end
