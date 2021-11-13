require 'rails_helper'

RSpec.describe 'Merchant Discounts Show Page' do
  it 'shows the discounts percentage and quantity' do
    merchant = Merchant.create!(name: 'Freddy Kruger')
    discount1 = Discount.create!(merchant_id: merchant.id, percentage: 0.25, quantity: 3)

    visit merchant_discount_path(merchant, discount1)

    expect(page).to have_content("Discount ##{discount1.id}")
    expect(page).to have_content("Percentage: 25%")
    expect(page).to have_content("Quantity: 3")
  end
end