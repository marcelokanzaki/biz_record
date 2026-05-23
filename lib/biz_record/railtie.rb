# frozen_string_literal: true

require "rails/railtie"

module BizRecord
  class Railtie < Rails::Railtie
    initializer "biz_record.active_record" do
      BizRecord.install_schedulable
    end
  end
end
