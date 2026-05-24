# frozen_string_literal: true

module BizRecord
  class HoursController < ApplicationController
    before_action :set_schedule
    before_action :set_weekday
    before_action :set_hour, only: %i[edit update destroy]

    rescue_from ArgumentError, with: :render_argument_error

    def new
    end

    def create
      @schedule.add_hours(@weekday, hour_params[:starts_at], hour_params[:ends_at])

      if @schedule.save
        redirect_to schedule_path(@schedule), notice: "Weekly hours updated."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @schedule.replace_hour(
        @weekday,
        @starts_at,
        @ends_at,
        hour_params[:starts_at],
        hour_params[:ends_at]
      )

      if @schedule.save
        redirect_to schedule_path(@schedule), notice: "Weekly hours updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @schedule.remove_hours(@weekday, @starts_at, @ends_at)
      @schedule.save!

      redirect_to schedule_path(@schedule), notice: "Weekly hours updated."
    end

    private

    def set_schedule
      @schedule = BizRecord::Schedule.find(params[:schedule_id])
    end

    def set_weekday
      @weekday = params[:weekday]
    end

    def set_hour
      @starts_at = params.require(:starts_at)
      @ends_at = @schedule.hours_for(@weekday).find { |starts_at, _| starts_at == @starts_at }&.last

      raise ArgumentError, "hours range does not exist" unless @ends_at
    end

    def hour_params
      permitted = params.require(:hour).permit(
        :starts_at,
        :ends_at,
        :"starts_at(4i)",
        :"starts_at(5i)",
        :"ends_at(4i)",
        :"ends_at(5i)"
      )

      {
        starts_at: permitted[:starts_at] || time_param(permitted, :starts_at),
        ends_at: permitted[:ends_at] || time_param(permitted, :ends_at)
      }
    end

    def time_param(params, attribute)
      hour = params[:"#{attribute}(4i)"]
      minute = params[:"#{attribute}(5i)"]

      return if hour.nil? || hour.empty? || minute.nil? || minute.empty?

      format("%02d:%02d", hour.to_i, minute.to_i)
    end

    def render_argument_error(error)
      @schedule.errors.add(:configuration, error.message)
      render action_name == "create" ? :new : :edit, status: :unprocessable_entity
    end
  end
end
