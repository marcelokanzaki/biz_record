module BizRecord::DaySubtypeTests
  extend ActiveSupport::Concern

  included do
    test "create touches schedule" do
      schedule = create_schedule!

      assert_changes -> { schedule.updated_at } do
        @klass.create!(schedule: schedule, date: "2026-06-01")
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

    test "requires schedule" do
      day = @klass.new(date: Date.current)

      assert_not day.valid?
      assert day.errors.where(:schedule, :blank).any?
    end

    test "requires date" do
      day = @klass.new(schedule: create_schedule!)

      assert_not day.valid?
      assert day.errors.where(:date, :blank).any?
    end

    test "requires unique date scoped by schedule and type" do
      schedule = create_schedule!

      @klass.create!(schedule: schedule, date: "2026-06-01")
      day = @klass.new(schedule: schedule, date: "2026-06-01")

      assert_not day.valid?
      assert day.errors.where(:date, :taken).any?
    end
  end
end
