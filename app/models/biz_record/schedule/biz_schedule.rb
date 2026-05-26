require "biz"

module BizRecord::Schedule::BizSchedule
  extend ActiveSupport::Concern

  def to_biz_schedule
    Biz::Schedule.new do |config|
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
    configuration.fetch("shifts").transform_keys(&:to_date)
  end

  def biz_holidays
    configuration.fetch("holidays").map(&:to_date)
  end
end
