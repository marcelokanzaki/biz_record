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
end
