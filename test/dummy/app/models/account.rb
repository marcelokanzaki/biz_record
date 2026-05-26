class Account < ApplicationRecord
  include BizRecord::HasSchedule

  has_schedule
  has_schedule :support
  has_schedule :dev
end
