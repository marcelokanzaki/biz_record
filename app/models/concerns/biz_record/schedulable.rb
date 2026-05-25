# frozen_string_literal: true

require "active_support/concern"

module BizRecord
  module Schedulable
    extend ActiveSupport::Concern

    class_methods do
      def has_biz_schedule(name = nil, dependent: :destroy, **options)
        schedule_key = name ? String(name) : BizRecord::Schedule::DEFAULT_KEY
        association_name = name ? :"#{schedule_key}_schedule" : :biz_schedule
        association_options = {
          as: :schedulable,
          class_name: "BizRecord::Schedule",
          dependent: dependent
        }.merge(options)

        has_one association_name, -> { where(key: schedule_key) }, **association_options
      end
    end
  end
end
