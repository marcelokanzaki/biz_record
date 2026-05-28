module BizRecord::TestHelpers
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
