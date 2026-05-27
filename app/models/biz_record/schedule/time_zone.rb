module BizRecord::Schedule::TimeZone
  extend ActiveSupport::Concern

  DEFAULT_TIME_ZONE = "Etc/UTC"

  included do
    validates :time_zone, presence: true
    validate :time_zone_exists
    before_create :set_default_time_zone
  end

  def time_zone=(value)
    run_callbacks(:time_zone_changed) { super }
  end

  private

  def time_zone_exists
    TZInfo::Timezone.get(time_zone)
  rescue TZInfo::InvalidTimezoneIdentifier
    errors.add(:time_zone, "is not a valid IANA time zone")
  end

  def set_default_time_zone
    self.time_zone = DEFAULT_TIME_ZONE unless time_zone.present?
  end
end
