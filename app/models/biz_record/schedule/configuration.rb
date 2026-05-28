module BizRecord::Schedule::Configuration
  extend ActiveSupport::Concern

  included do
    before_validation :build_default_intervals
    before_create -> { self[:configuration] = configuration_bundle }

    after_touch :bundle_configuration
  end

  def configuration=(_)
    raise NoMethodError, "configuration is derived from schedule records and cannot be assigned directly"
  end

  private

  def build_default_intervals
    BizRecord.default_hours.each do |weekday, hours|
      hours.each do |starts_at, ends_at|
        intervals.build(weekday: weekday, starts_at: starts_at, ends_at: ends_at)
      end
    end
  end

  def configuration_bundle
    {
      "hours"    => weekly_hours_bundle,
      "shifts"   => days_bundle_for(shift_days),
      "breaks"   => days_bundle_for(break_days),
      "holidays" => holidays_bundle
    }
  end

  def bundle_configuration
    update_column(:configuration, configuration_bundle)
  end

  def weekly_hours_bundle
    intervals_by_weekday = intervals.group_by(&:weekday)

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

      output_hash[day.to_s] = intervals_hash_from(interval_records)
    end
  end

  def holidays_bundle
    holiday_days.all.map(&:to_s).uniq.sort
  end

  def intervals_hash_from(interval_records)
    interval_records.each_with_object({}) do |interval_record, output_hash|
      output_hash[interval_record.formatted_starts_at] = interval_record.formatted_ends_at
    end
  end
end
