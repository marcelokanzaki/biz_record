# frozen_string_literal: true

require "active_record"
require "biz"
require_relative "biz_record/version"
require_relative "biz_record/support/date_values"
require_relative "biz_record/support/time_ranges"
require_relative "biz_record/schedule"
require_relative "biz_record/schedulable"
require_relative "biz_record/railtie" if defined?(Rails::Railtie)

module BizRecord
end

ActiveRecord::Base.include BizRecord::Schedulable
