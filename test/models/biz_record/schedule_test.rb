require "test_helper"

class BizRecord::ScheduleTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "default hours" do
    BizRecord.configure do |config|
      config.default_hours = {
        sun: [["10:00", "14:00"]]
      }
    end

    schedule = create_schedule!
    assert_equal({ sun: { "10:00" => "14:00" } }, schedule.biz_hours)
  end

  test "belongs to a schedulable" do
    schedule = BizRecord::Schedule.create!(schedulable: account)
    assert_equal account, schedule.schedulable
  end

  test "schedulable is required" do
    schedule = BizRecord::Schedule.new

    refute schedule.valid?
    assert schedule.errors[:schedulable].any?
  end
end
