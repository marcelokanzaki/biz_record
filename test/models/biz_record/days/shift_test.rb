require "test_helper"

class BizRecord::Days::ShiftTest < ActiveSupport::TestCase
  include BizRecord::DaySubtypeTests

  setup do
    @klass = BizRecord::Days::Shift
    BizRecord::Schedule.delete_all
    Account.delete_all
  end
end
