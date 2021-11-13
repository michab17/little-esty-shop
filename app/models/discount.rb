class Discount < ApplicationRecord
  belongs_to :merchant

  def percent
    "#{(percentage * 100).to_i}%"
  end
end