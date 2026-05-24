# frozen_string_literal: true

require "test_helper"

module BizRecord
  class TimezoneTest < ActiveSupport::TestCase
    setup do
      Schedule.delete_all
      Account.delete_all
    end

    test "requires valid time zone" do
      schedule = Schedule.new(time_zone: "Mars/Base")

      refute schedule.valid?
      assert_includes schedule.errors[:time_zone], "is not a valid IANA time zone"
    end
  end
end
