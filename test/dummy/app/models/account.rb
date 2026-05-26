class Account < ApplicationRecord
  include BizRecord::Schedulable

  has_biz_schedule
  has_biz_schedule :support
  has_biz_schedule :dev
end
