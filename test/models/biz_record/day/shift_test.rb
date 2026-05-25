# frozen_string_literal: true

require "test_helper"

class BizRecord::DayShiftTest < ActiveSupport::TestCase
  setup do
    BizRecord::Schedule.delete_all
    Account.delete_all
  end

  test "create touches schedule" do
    schedule = create_schedule!

    assert_changes -> { schedule.updated_at } do
      schedule.shift_days.create!(date: "2026-06-01")
    end
  end

  test "update touches schedule" do
    schedule = create_schedule!
    shift = schedule.shift_days.create!(date: "2026-06-01")

    assert_changes -> { schedule.updated_at } do
      shift.update!(date: "2026-06-02")
    end
  end

  test "destroy touches schedule" do
    schedule = create_schedule!
    shift = schedule.shift_days.create!(date: "2026-06-01")

    assert_changes -> { schedule.updated_at } do
      shift.destroy!
    end
  end
end
