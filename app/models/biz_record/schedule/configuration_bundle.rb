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
      "shifts"   => days_bundle_for(shift_days),
      "breaks"   => days_bundle_for(break_days),
      "holidays" => holidays_bundle
    }
  end

  def weekly_hours_bundle
    intervals_by_weekday = intervals.order(:starts_at).group_by(&:weekday)

    BizRecord::WEEKDAYS.each_with_object({}) do |weekday, output_hash|
      interval_records = intervals_by_weekday.fetch(weekday, [])
      next if interval_records.empty?

      output_hash[weekday] = intervals_hash_from(interval_records)
    end
  end

  def days_bundle_for(days)
    day_records = days.includes(:intervals)

    day_records.each_with_object({}) do |day, output_hash|
      interval_records = day.intervals.sort_by(&:starts_at)
      next if interval_records.empty?

      output_hash[day.date_string] = intervals_hash_from(interval_records)
    end
  end

  def holidays_bundle
    holiday_days.all.map(&:date_string).uniq.sort
  end

  def intervals_hash_from(interval_records)
    interval_records.each_with_object({}) do |interval_record, output_hash|
      output_hash[interval_record.starts_at_string] = interval_record.ends_at_string
    end
  end
end
