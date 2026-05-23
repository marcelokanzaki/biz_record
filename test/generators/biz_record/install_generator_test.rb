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
        end
      end
    end
  end
end
