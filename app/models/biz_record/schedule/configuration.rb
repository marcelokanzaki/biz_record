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
        intervals.build(weekday:, starts_at:, ends_at:)
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
    intervals.group_by(&:weekday).transform_values { |it| BizRecord::Interval.to_configuration(it) }
  end

  def days_bundle_for(days)
    days.where.associated(:intervals).distinct.includes(:intervals)
      .index_by(&:date)
      .transform_values { |day| BizRecord::Interval.to_configuration(day.intervals) }
      .transform_keys(&:to_s)
  end

  def holidays_bundle
    holiday_days.map(&:date).map(&:to_s)
  end
end
