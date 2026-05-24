# frozen_string_literal: true

BizRecord::Engine.routes.draw do
  resources :schedules, only: %i[show]

  scope "schedules/:schedule_id", as: :schedule do
    scope path: ":weekday", as: :weekday do
      resources :intervals, only: %i[new create edit update destroy]
    end
  end
end
