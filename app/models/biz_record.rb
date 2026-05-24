# frozen_string_literal: true

require "active_support/lazy_load_hooks"

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
