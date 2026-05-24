# frozen_string_literal: true

BizRecord::Engine.routes.draw do
  resources :schedules, only: %i[show]

  scope "schedules/:schedule_id", as: :schedule do
    resources :shifts, only: %i[new create edit update destroy] do
      resources :intervals, only: %i[new create edit update destroy]
    end

    scope path: ":weekday", as: :weekday do
      resources :intervals, only: %i[new create edit update destroy]
    end
  end
end
