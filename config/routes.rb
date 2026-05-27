BizRecord::Engine.routes.draw do
  root to: "schedules#index"

  resources :schedules, only: %i[index show] do
    interval_actions = %i[new create edit update destroy]

    with_options path: ":weekday/intervals", constraints: { weekday: Regexp.union(BizRecord::WEEKDAYS) } do
      resources :intervals, only: interval_actions
    end

    resources :shifts, only: %i[new create edit update destroy] do
      resources :intervals, only: interval_actions
    end

    resources :breaks, only: %i[new create edit update destroy] do
      resources :intervals, only: interval_actions
    end

    resources :holidays, only: %i[new create edit update destroy]
  end
end
