# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "biz_record/engine"

module BizRecordControllerTestApp
  class Application < Rails::Application
    config.root = File.expand_path("../../../tmp/controller_app", __dir__)
    config.eager_load = false
    config.secret_key_base = "biz-record-test"
    config.hosts.clear
  end
end

BizRecordControllerTestApp::Application.initialize!
BizRecordControllerTestApp::Application.routes.draw do
  mount BizRecord::Engine, at: "/biz_record"
end
