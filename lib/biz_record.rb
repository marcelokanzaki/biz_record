# frozen_string_literal: true

require "active_record"
require "biz"
require_relative "biz_record/version"
require_relative "biz_record/schedule/holidays"
require_relative "biz_record/schedule/weekly_hours"
require_relative "biz_record/schedule"
require_relative "biz_record/railtie" if defined?(Rails::Railtie)

module BizRecord
end
