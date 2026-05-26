# frozen_string_literal: true

require "test_helper"

class BizRecord::Days::BreakTest < ActiveSupport::TestCase
  include BizRecord::DaySubtypeTests

  setup do
    @klass = BizRecord::Days::Break
    BizRecord::Schedule.delete_all
    Account.delete_all
  end
end
