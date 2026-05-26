# frozen_string_literal: true

module BizRecord
  class BreaksController < ApplicationController
    before_action :set_schedule
    before_action :set_break_day, only: %i[edit update destroy]

    def new
      @break_day = @schedule.break_days.build
    end

    def create
      @break_day = @schedule.break_days.build(break_params)

      if @break_day.save
        redirect_to schedule_path(@schedule), notice: "Breaks updated."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @break_day.update(break_params)
        redirect_to schedule_path(@schedule), notice: "Breaks updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @break_day.destroy!

      redirect_to schedule_path(@schedule), notice: "Breaks updated."
    end

    private

    def set_schedule
      @schedule = BizRecord::Schedule.find(params[:schedule_id])
    end

    def set_break_day
      @break_day = @schedule.break_days.find(params[:id])
    end

    def break_params
      params.require(:break).permit(:date)
    end
  end
end
