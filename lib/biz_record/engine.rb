# frozen_string_literal: true

require "rails"
require "action_dispatch"
require_relative "../../app/models/biz_record"

module BizRecord
  class Engine < Rails::Engine
    isolate_namespace BizRecord

    initializer "biz_record.active_record" do
      BizRecord.install_schedulable
    end
  end
end
