require "test_helper"

class BizRecord::ConfigurationBundleTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "does not allow configuration assignment" do
    schedule = create_schedule!

    assert_raises(NoMethodError) do
      schedule.configuration = {}
    end
  end

  test "#touch rebuilds configuration" do
    schedule = create_schedule!

    assert_queries_match(/UPDATE "biz_record_schedules" SET "configuration"/, count: 1) do
      schedule.touch
    end
  end
end
