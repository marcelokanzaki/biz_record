require "test_helper"
require "rails/generators/test_case"
require "generators/biz_record/install_generator"

module BizRecord
  module Generators
    class InstallGeneratorTest < Rails::Generators::TestCase
      tests InstallGenerator
      destination File.expand_path("../../../tmp/generators", __dir__)

      setup do
        prepare_destination
      end

      test "generates schedule migration" do
        run_generator

        assert_migration "db/migrate/create_biz_record_schedules.rb"
      end
    end
  end
end
