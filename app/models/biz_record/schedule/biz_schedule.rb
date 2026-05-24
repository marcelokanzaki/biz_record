module BizRecord::Schedule::BizSchedule
  extend ActiveSupport::Concern

  def to_biz_schedule
    Biz::Schedule.new do |config|
      config.hours = biz_hours
      config.shifts = biz_date_hours("shifts")
      config.breaks = biz_date_hours("breaks")
      config.holidays = biz_holidays
      config.time_zone = time_zone
    end
  end

  private

  def biz_hours
    symbolize_weekdays(hours)
  end

  def biz_date_hours(key)
    date_hours = configuration_data.fetch(key)
    return date_hours unless date_hours.respond_to?(:to_h)

    date_hours.to_h.each_with_object({}) do |(date, ranges), converted|
      converted[date_value(date)] = ranges
    end
  end

  def biz_holidays
    holidays.map { |date| date_value(date) }
  end

  def symbolize_weekdays(configured_hours)
    return configured_hours unless configured_hours.respond_to?(:to_h)

    configured_hours.to_h.each_with_object({}) do |(weekday, ranges), converted|
      converted[weekday.respond_to?(:to_sym) ? weekday.to_sym : weekday] = ranges
    end
  end

  def date_value(date)
    return date.to_date if date.respond_to?(:to_date)
    return ::Date.iso8601(date) if date.is_a?(String)

    date
  rescue ArgumentError
    date
  end
end
