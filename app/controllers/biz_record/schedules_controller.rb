# frozen_string_literal: true

module BizRecord
  class SchedulesController < ApplicationController
    before_action :set_schedule

    def show
    end

    private

    def set_schedule
      @schedule = BizRecord::Schedule.find(params[:id])
    end
  end
end
