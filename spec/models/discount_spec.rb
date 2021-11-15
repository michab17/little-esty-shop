require 'rails_helper'

RSpec.describe Discount do
  it { should belong_to :merchant }

  describe '#percent' do
    it 'returns the percentage value as a percent' do
      merchant = Merchant.create!(name: 'merchant')
      discount = merchant.discounts.create!(percentage: 0.20, quantity: 3)

      expect(discount.percent).to eq('20%')
    end
  end
end