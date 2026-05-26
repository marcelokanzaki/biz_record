require "test_helper"

class BizRecord::Days::HolidayTest < ActiveSupport::TestCase
  include BizRecord::DaySubtypeTests

  setup do
    @klass = BizRecord::Days::Holiday
    BizRecord::Schedule.delete_all
    Account.delete_all
  end
end
