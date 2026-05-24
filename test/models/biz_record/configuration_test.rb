# frozen_string_literal: true

require "test_helper"

module BizRecord
  class ConfigurationTest < ActiveSupport::TestCase
    test "defaults to a business week" do
      assert_equal(
        {
          "mon" => { "09:00" => "17:00" },
          "tue" => { "09:00" => "17:00" },
          "wed" => { "09:00" => "17:00" },
          "thu" => { "09:00" => "17:00" },
          "fri" => { "09:00" => "17:00" }
        },
        BizRecord.configuration.default_hours
      )
    end

    test "configures default hours" do
      BizRecord.configure do |config|
        config.default_hours = {
          sun: [["10:00", "14:00"]],
          mon: {
            "9:00" => "12:00",
            "13:00" => "17:00"
          }
        }
      end

      assert_equal(
        {
          "sun" => { "10:00" => "14:00" },
          "mon" => {
            "09:00" => "12:00",
            "13:00" => "17:00"
          }
        },
        BizRecord.configuration.default_hours
      )
    end

    test "rejects non hash default hours" do
      error = assert_raises(ArgumentError) do
        BizRecord.configure { |config| config.default_hours = "invalid" }
      end

      assert_equal "default_hours must be a hash", error.message
    end

    test "rejects invalid default hours" do
      error = assert_raises(ArgumentError) do
        BizRecord.configure { |config| config.default_hours = { nope: [["09:00", "17:00"]] } }
      end

      assert_equal "weekday must be one of: sun, mon, tue, wed, thu, fri, sat", error.message

      assert_raises(ArgumentError) do
        BizRecord.configure { |config| config.default_hours = { mon: [["17:00", "09:00"]] } }
      end
    end
  end
end
