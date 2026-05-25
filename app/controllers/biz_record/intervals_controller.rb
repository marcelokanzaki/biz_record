# frozen_string_literal: true

module BizRecord
  class IntervalsController < ApplicationController
    before_action :set_schedule
    before_action :set_interval_owner
    before_action :set_interval, only: %i[edit update destroy]

    def new
      @interval = @interval_owner.intervals.build(weekday: @weekday)
    end

    def create
      @interval = @interval_owner.intervals.build(interval_params.merge(weekday: @weekday))

      if @interval.save
        redirect_to schedule_path(@schedule), notice: "Schedule updated."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @interval.update(interval_params)
        redirect_to schedule_path(@schedule), notice: "Schedule updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @interval.destroy!

      redirect_to schedule_path(@schedule), notice: "Schedule updated."
    end

    helper_method :interval_path_for

    private

    def set_schedule
      @schedule = BizRecord::Schedule.find(params[:schedule_id])
    end

    def set_interval_owner
      if params[:shift_id].present?
        @interval_owner = @schedule.shift_days.find(params[:shift_id])
      elsif params[:break_id].present?
        @interval_owner = @schedule.break_days.find(params[:break_id])
      else
        @weekday = params[:weekday]
        @interval_owner = @schedule
      end
    end

    def set_interval
      @interval = @interval_owner.intervals.find(params[:id])
    end

    def interval_params
      params.require(:interval).permit(:starts_at, :ends_at)
    end

    def interval_path_for(schedule, owner, interval, weekday)
      case owner
      when BizRecord::Schedule
        interval.persisted? ?
          schedule_interval_path(schedule, interval, weekday: weekday) :
          schedule_intervals_path(schedule, weekday: weekday)
      when BizRecord::Days::Shift
        interval.persisted? ?
          schedule_shift_interval_path(schedule, owner, interval) :
          schedule_shift_intervals_path(schedule, owner)
      when BizRecord::Days::Break
        interval.persisted? ?
          schedule_break_interval_path(schedule, owner, interval) :
          schedule_break_intervals_path(schedule, owner)
      end
    end
  end
end
