class Account < ApplicationRecord
  has_biz_schedule
  has_biz_schedule :support
  has_biz_schedule :dev
end
