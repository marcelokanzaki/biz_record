module BizRecord::Schedule::TimeZone
  extend ActiveSupport::Concern

  included do
    define_model_callbacks :time_zone_change, only: :after

    before_validation :set_default_time_zone, on: :create

    validates :time_zone, presence: true
    validate :time_zone_exists
  end

  def time_zone=(value)
    run_callbacks(:time_zone_change) { super }
  end

  private

  def set_default_time_zone
    self.time_zone = BizRecord.default_time_zone if time_zone.blank?
  end

  def time_zone_exists
    TZInfo::Timezone.get(time_zone)
  rescue TZInfo::InvalidTimezoneIdentifier
    errors.add(:time_zone, "is not a valid IANA time zone")
  end
end
