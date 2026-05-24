# frozen_string_literal: true

module BizRecord
  class IntervalsController < ApplicationController
    before_action :set_schedule
    before_action :set_weekday
    before_action :set_interval, only: %i[edit update destroy]

    def new
      @interval = @schedule.intervals.build(weekday: @weekday)
    end

    def create
      @interval = @schedule.intervals.build(interval_params.merge(weekday: @weekday))

      if @interval.save
        redirect_to schedule_path(@schedule), notice: "Weekly hours updated."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @interval.update(interval_params)
        redirect_to schedule_path(@schedule), notice: "Weekly hours updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @interval.destroy!

      redirect_to schedule_path(@schedule), notice: "Weekly hours updated."
    end

    private

    def set_schedule
      @schedule = BizRecord::Schedule.find(params[:schedule_id])
    end

    def set_weekday
      @weekday = params[:weekday]
    end

    def set_interval
      @interval = @schedule.intervals.where(weekday: @weekday).find(params[:id])
    end

    def interval_params
      params.require(:interval).permit(:starts_at, :ends_at)
    end
  end
end
