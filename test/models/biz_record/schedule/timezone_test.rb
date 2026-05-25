# frozen_string_literal: true

require "test_helper"

class BizRecord::TimezoneTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "requires valid time zone" do
    schedule = BizRecord::Schedule.new(time_zone: "Mars/Base")

    refute schedule.valid?
    assert_includes schedule.errors[:time_zone], "is not a valid IANA time zone"
  end
end
