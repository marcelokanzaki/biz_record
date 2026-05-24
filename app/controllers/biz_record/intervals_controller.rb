# frozen_string_literal: true

module BizRecord
  class IntervalsController < ApplicationController
    before_action :set_schedule
    before_action :set_interval_owner
    before_action :set_interval, only: %i[edit update destroy]

    def new
      @interval = @interval_owner.intervals.build(interval_context_attributes)
    end

    def create
      @interval = @interval_owner.intervals.build(interval_params.merge(interval_context_attributes))

      if @interval.save
        redirect_to schedule_path(@schedule), notice: "#{interval_context_name} updated."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @interval.update(interval_params)
        redirect_to schedule_path(@schedule), notice: "#{interval_context_name} updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @interval.destroy!

      redirect_to schedule_path(@schedule), notice: "#{interval_context_name} updated."
    end

    helper_method :interval_form_url,
                  :interval_form_method,
                  :interval_page_title,
                  :interval_submit_label

    private

    def set_schedule
      @schedule = BizRecord::Schedule.find(params[:schedule_id])
    end

    def set_interval_owner
      if params[:shift_id].present?
        @shift = @schedule.shift_days.find(params[:shift_id])
        @interval_owner = @shift
      else
        @weekday = params[:weekday]
        @interval_owner = @schedule
      end
    end

    def set_interval
      intervals = @interval_owner.intervals
      intervals = intervals.where(weekday: @weekday) if @interval_owner == @schedule

      @interval = intervals.find(params[:id])
    end

    def interval_params
      params.require(:interval).permit(:starts_at, :ends_at)
    end

    def interval_context_attributes
      @shift.present? ? {} : { weekday: @weekday }
    end

    def interval_context_name
      @shift.present? ? "Shifts" : "Weekly hours"
    end

    def interval_form_url
      if @shift.present?
        return schedule_shift_interval_path(@schedule, @shift, @interval) if @interval.persisted?

        schedule_shift_intervals_path(@schedule, @shift)
      else
        return schedule_weekday_interval_path(@schedule, @weekday, @interval) if @interval.persisted?

        schedule_weekday_intervals_path(@schedule, @weekday)
      end
    end

    def interval_form_method
      @interval.persisted? ? :patch : :post
    end

    def interval_page_title
      action = @interval.persisted? ? "Edit" : "Add"

      @shift.present? ? "#{action} #{shift_date_label} shift hours" : "#{action} #{@weekday} hours"
    end

    def interval_submit_label
      action = @interval.persisted? ? "Save" : "Add"

      @shift.present? ? "#{action} shift hours" : "#{action} hours"
    end

    def shift_date_label
      @shift.date_string || "shift"
    end
  end
end
