module BizRecord
  module Days
    class Break < BizRecord::Day
      has_many :intervals, -> { chronological }, as: :owner, class_name: "BizRecord::Interval", dependent: :delete_all
    end
  end
end
