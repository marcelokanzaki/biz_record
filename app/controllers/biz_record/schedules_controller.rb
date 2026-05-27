module BizRecord
  class SchedulesController < ApplicationController
    before_action :set_schedule, only: %i[show]

    def index
      @schedules = Schedule.all.order(created_at: :desc)
    end

    def show
    end

    private

    def set_schedule
      @schedule = BizRecord::Schedule.find(params[:id])
    end
  end
end
