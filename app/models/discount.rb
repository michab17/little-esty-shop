class Discount < ApplicationRecord
  belongs_to :merchant

  def percent
    "#{(percentage * 100).to_i}%"
  end

  def self.quantity_array
    map do |discount|
      discount.quantity
    end
  end
end