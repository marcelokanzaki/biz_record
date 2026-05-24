# frozen_string_literal: true

module BizRecord
  class ApplicationController < ActionController::Base
    layout false

    helper_method :time_select_value

    private

    def time_select_value(value)
      return if value.nil? || value.empty?

      hour, minute = value.split(":").map(&:to_i)
      Time.utc(2000, 1, 1, hour, minute)
    end
  end
end
