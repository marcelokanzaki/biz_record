# test/models/biz_record/day_test.rb

require "test_helper"

class BizRecord::DayTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "cannot instantiate base class directly" do
    day = BizRecord::Day.new(
      schedule: create_schedule!,
      date: Date.current
    )

    assert_not day.valid?
    assert day.errors.where(:type, :inclusion).any?
  end

  test "returns date as biz schedule format" do
    day = BizRecord::Days::Holiday.new(
      schedule: create_schedule!,
      date: Date.new(2026, 6, 1)
    )

    assert_equal "2026-06-01", day.to_biz_schedule
  end
end
