module BizRecord::Schedule::ConfigurationBundle
  extend ActiveSupport::Concern

  included do
    after_touch :bundle_configuration
  end

  private

  def bundle_configuration
    update_column(:configuration, configuration_bundle)
  end

  def configuration_bundle
    {
      "hours"    => weekly_hours_bundle,
      "shifts"   => days_bundle_for(BizRecord::Days::Shift),
      "breaks"   => days_bundle_for(BizRecord::Days::Break),
      "holidays" => holidays_bundle
    }
  end

  def weekly_hours_bundle
    intervals_by_weekday = BizRecord::Interval
      .where(owner_type: self.class.name, owner_id: id)
      .where.not(weekday: nil)
      .order(:starts_at)
      .group_by(&:weekday)

    BizRecord::WEEKDAYS.each_with_object({}) do |weekday, configured_hours|
      weekday_intervals = intervals_by_weekday.fetch(weekday, [])
      next if weekday_intervals.empty?

      configured_hours[weekday] = time_ranges_for(weekday_intervals)
    end
  end

  def days_bundle_for(day_class)
    days = day_class
      .where(schedule_id: id)
      .order(:date)
      .includes(:intervals)

    days.each_with_object({}) do |day, configured_hours|
      day_intervals = day.intervals.sort_by(&:starts_at)
      next if day_intervals.empty?

      configured_hours[day.date_string] = time_ranges_for(day_intervals)
    end
  end

  def holidays_bundle
    BizRecord::Days::Holiday
      .where(schedule_id: id)
      .order(:date)
      .map(&:date_string)
      .uniq
      .sort
  end

  def time_ranges_for(intervals)
    intervals.each_with_object({}) do |interval, time_ranges|
      time_ranges[interval.starts_at_string] = interval.ends_at_string
    end
  end
end
