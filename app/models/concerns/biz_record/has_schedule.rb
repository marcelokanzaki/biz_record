module BizRecord
  module HasSchedule
    extend ActiveSupport::Concern

    class_methods do
      def has_schedule(name = nil, dependent: :destroy, **options)
        schedule_key = name ? String(name) : BizRecord::DEFAULT_KEY
        association_name = name ? :"#{schedule_key}_schedule" : :schedule
        association_options = {
          as: :schedulable,
          class_name: "BizRecord::Schedule",
          dependent: dependent
        }.merge(options)

        has_one association_name, -> { where(key: schedule_key) }, **association_options
      end
    end
  end
end
