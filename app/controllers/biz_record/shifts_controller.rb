module BizRecord
  class ShiftsController < ApplicationController
    before_action :set_schedule
    before_action :set_shift, only: %i[edit update destroy]

    def new
      @shift = @schedule.shift_days.build
    end

    def create
      @shift = @schedule.shift_days.build(shift_params)

      if @shift.save
        redirect_to schedule_path(@schedule), notice: "Shifts updated."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @shift.update(shift_params)
        redirect_to schedule_path(@schedule), notice: "Shifts updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @shift.destroy!

      redirect_to schedule_path(@schedule), notice: "Shifts updated."
    end

    private

    def set_schedule
      @schedule = BizRecord::Schedule.find(params[:schedule_id])
    end

    def set_shift
      @shift = @schedule.shift_days.find(params[:id])
    end

    def shift_params
      params.require(:shift).permit(:date)
    end
  end
end
