require "test_helper"

class BizRecord::TimeZoneTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
    @original_time_zone = Rails.application.config.time_zone
  end

  teardown do
    Rails.application.config.time_zone = @original_time_zone
  end

  test "defaults to the Rails application time zone" do
    Rails.application.config.time_zone = "Brasilia"

    schedule = create_schedule!

    assert_equal "America/Sao_Paulo", schedule.time_zone
  end

  test "keeps an explicitly configured time zone" do
    Rails.application.config.time_zone = "Brasilia"

    schedule = create_schedule!(time_zone: "Etc/UTC")

    assert_equal "Etc/UTC", schedule.time_zone
  end

  test "defaults blank time zone to the Rails application time zone" do
    Rails.application.config.time_zone = "Brasilia"

    schedule = create_schedule!(time_zone: "")

    assert_equal "America/Sao_Paulo", schedule.time_zone
  end

  test "defaults to UTC when the Rails application time zone is blank" do
    Rails.application.config.time_zone = ""

    schedule = create_schedule!

    assert_equal "Etc/UTC", schedule.time_zone
  end

  test "requires valid time zone" do
    schedule = BizRecord::Schedule.new(time_zone: "Mars/Base")

    refute schedule.valid?
    assert_includes schedule.errors[:time_zone], "is not a valid IANA time zone"
  end
end
