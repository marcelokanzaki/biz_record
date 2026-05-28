ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"
require "debug"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |f| require f }

module ActiveSupport
  class TestCase
    include BizRecord::TestHelpers

    setup do
      Account.delete_all

      BizRecord::Schedule.delete_all
      BizRecord::Interval.delete_all
      BizRecord::Day.delete_all

      BizRecord.reset_configuration!
    end
  end
end
