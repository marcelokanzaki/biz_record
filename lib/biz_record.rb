# frozen_string_literal: true

require "active_record"
require "active_support/lazy_load_hooks"
require "biz"
require_relative "biz_record/version"
require_relative "biz_record/support/date_values"
require_relative "biz_record/support/time_ranges"
require_relative "biz_record/configuration"
require_relative "biz_record/schedule"
require_relative "biz_record/interval"
require_relative "biz_record/day"
require_relative "biz_record/schedulable"

module BizRecord
  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset_configuration!
    @configuration = Configuration.new
  end

  def self.install_schedulable
    ActiveSupport.on_load(:active_record) do
      include BizRecord::Schedulable
    end
  end
end

if defined?(Rails::Engine)
  require_relative "biz_record/engine"
elsif defined?(Rails::Railtie)
  require_relative "biz_record/railtie"
else
  BizRecord.install_schedulable
end
