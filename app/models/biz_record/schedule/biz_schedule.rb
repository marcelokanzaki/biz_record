require "biz"

module BizRecord::Schedule::BizSchedule
  extend ActiveSupport::Concern

  included do
    after_touch :reset_biz_schedule
    after_time_zone_change :reset_biz_schedule
    after_reload :reset_biz_schedule

    delegate :in_hours?, :on_break?, :on_holiday?, :time, :within, :periods, to: :biz_schedule
  end

  def biz_schedule
    @biz_schedule ||= Biz::Schedule.new do |config|
      config.hours     = biz_hours
      config.shifts    = biz_shifts
      config.breaks    = biz_breaks
      config.holidays  = biz_holidays
      config.time_zone = time_zone
    end
  end

  def biz_hours
    configuration.fetch("hours").symbolize_keys
  end

  def biz_shifts
    configuration.fetch("shifts").transform_keys(&:to_date)
  end

  def biz_breaks
    configuration.fetch("breaks").transform_keys(&:to_date)
  end

  def biz_holidays
    configuration.fetch("holidays").map(&:to_date)
  end

  def reload_biz_schedule
    reset_biz_schedule
    biz_schedule
  end

  private

  def reset_biz_schedule
    remove_instance_variable(:@biz_schedule) if instance_variable_defined?(:@biz_schedule)
  end
end
