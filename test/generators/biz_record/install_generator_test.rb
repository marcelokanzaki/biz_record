# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"
require "generators/biz_record/install_generator"

module BizRecord
  module Generators
    class InstallGeneratorTest < Rails::Generators::TestCase
      tests InstallGenerator
      destination File.expand_path("../../../tmp/generators", __dir__)

      setup :prepare_destination

      def test_generates_schedule_migration
        run_generator

        assert_migration "db/migrate/create_biz_record_schedules.rb" do |migration|
          assert_includes migration, "create_table :biz_record_schedules"
          assert_includes migration, "t.references :schedulable, polymorphic: true, null: false, index: false"
          assert_includes migration, "t.public_send(configuration_column_type, :configuration, null: false)"
          assert_includes migration, "[:schedulable_type, :schedulable_id, :key]"
          assert_includes migration, "unique: true"
          assert_includes migration, ":jsonb"
          assert_includes migration, ":json"
          assert_includes migration, "create_table :biz_record_days"
          assert_includes migration, "t.references :schedule, null: false, index: false"
          assert_includes migration, "t.string :type, null: false"
          assert_includes migration, "t.date :date, null: false"
          assert_includes migration, "index_biz_record_days_on_schedule_type_and_date"
          assert_includes migration, "create_table :biz_record_intervals"
          assert_includes migration, "t.references :owner, polymorphic: true, null: false, index: false"
          assert_includes migration, "t.time :starts_at, null: false"
          assert_includes migration, "t.time :ends_at, null: false"
          assert_includes migration, "index_biz_record_intervals_on_owner_weekday_and_starts_at"
        end
      end
    end
  end
end
