module BizRecord::Schedule::Timezone
  extend ActiveSupport::Concern

  DEFAULT_TIME_ZONE = "Etc/UTC"

  included do
    validates :time_zone, presence: true
    validate :time_zone_exists
    before_create :set_default_timezone
  end

  def time_zone=(value)
    reset_biz_schedule
    super
  end

  private

  def time_zone_exists
    TZInfo::Timezone.get(time_zone)
  rescue TZInfo::InvalidTimezoneIdentifier
    errors.add(:time_zone, "is not a valid IANA time zone")
  end

  def set_default_timezone
    self.time_zone = DEFAULT_TIME_ZONE unless time_zone.present?
  end
end
