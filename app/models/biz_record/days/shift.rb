module BizRecord
  module Days
    class Shift < BizRecord::Day
      has_many :intervals, as: :owner, class_name: "BizRecord::Interval", dependent: :delete_all
    end
  end
end
