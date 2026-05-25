module BizRecord::Schedule::Key
  extend ActiveSupport::Concern

  DEFAULT_KEY = "default"

  included do
    validates :key, presence: true
    validates :key, uniqueness: { scope: %i[schedulable_type schedulable_id] }

    before_create :set_default_key
  end

  private

  def set_default_key
    self.key = DEFAULT_KEY unless key.present?
  end
end
