# frozen_string_literal: true

require "test_helper"

module BizRecord
  class ConfigurationTest < ActiveSupport::TestCase
    test "defaults to a business week" do
      assert_equal(
        {
          mon: { "09:00" => "17:00" },
          tue: { "09:00" => "17:00" },
          wed: { "09:00" => "17:00" },
          thu: { "09:00" => "17:00" },
          fri: { "09:00" => "17:00" }
        },
        BizRecord.default_hours
      )
    end

    test "keeps configured default hours as provided" do
      default_hours = {
        sun: [["10:00", "14:00"]],
        mon: {
          "9:00" => "12:00",
          "13:00" => "17:00"
        }
      }

      BizRecord.configure do |config|
        config.default_hours = default_hours
      end

      assert_equal default_hours, BizRecord.default_hours
    end

    test "does not validate configured default hours" do
      BizRecord.configure do |config|
        config.default_hours = { nope: [["09:00", "17:00"]] }
      end

      assert_equal({ nope: [["09:00", "17:00"]] }, BizRecord.default_hours)
    end
  end
end
