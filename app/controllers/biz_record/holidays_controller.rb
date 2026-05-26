module BizRecord
  class HolidaysController < ApplicationController
    before_action :set_schedule
    before_action :set_holiday, only: %i[edit update destroy]

    def new
      @holiday = @schedule.holiday_days.build
    end

    def create
      @holiday = @schedule.holiday_days.build(holiday_params)

      if @holiday.save
        redirect_to schedule_path(@schedule), notice: "Holidays updated."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @holiday.update(holiday_params)
        redirect_to schedule_path(@schedule), notice: "Holidays updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @holiday.destroy!

      redirect_to schedule_path(@schedule), notice: "Holidays updated."
    end

    private

    def set_schedule
      @schedule = BizRecord::Schedule.find(params[:schedule_id])
    end

    def set_holiday
      @holiday = @schedule.holiday_days.find(params[:id])
    end

    def holiday_params
      params.require(:holiday).permit(:date)
    end
  end
end
