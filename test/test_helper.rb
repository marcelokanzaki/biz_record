ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"
require "debug"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |f| require f }

module BizRecordTestHelpers
  extend ActiveSupport::Concern

  included do
    setup do
      BizRecord::Interval.delete_all
      BizRecord::Day.delete_all
      BizRecord::Schedule.delete_all
      Account.delete_all
      BizRecord.reset_configuration!
    end
  end

  def account
    @account ||= Account.create!(name: "Acme")
  end

  def build_schedule(attributes = {})
    BizRecord::Schedule.new({ schedulable: account }.merge(attributes))
  end

  def create_schedule!(attributes = {})
    BizRecord::Schedule.create!({ schedulable: account }.merge(attributes))
  end
end

ActiveSupport::TestCase.include BizRecordTestHelpers

if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [File.expand_path("fixtures", __dir__)]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures/files", __dir__)
  ActiveSupport::TestCase.fixtures :all
end
