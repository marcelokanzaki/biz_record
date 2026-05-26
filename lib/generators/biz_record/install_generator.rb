require "rails/generators"
require "rails/generators/active_record"

module BizRecord
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def copy_migration
        migration_template "create_biz_record_schedules.rb.tt",
                           "db/migrate/create_biz_record_schedules.rb"
      end

      def show_next_steps
        say <<~MESSAGE

          BizRecord installed.

          Next steps:
            bin/rails db:migrate
            Add include BizRecord::HasSchedule
            and has_schedule to each model that will have a schedule.

        MESSAGE
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      private

      def migration_version
        "[#{ActiveRecord::Migration.current_version}]"
      end
    end
  end
end
