module BizRecord::Schedule::Reload
  extend ActiveSupport::Concern

  included do
    define_model_callbacks :reload, only: :after
  end

  def reload(*args)
    run_callbacks(:reload) { super }
  end
end
