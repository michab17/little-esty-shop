require 'rails_helper'

RSpec.describe 'Merchant Discount Index Page' do
  it 'diplays all of the merchants discounts' do
    merchant = Merchant.create!(name: 'Freddy Kruger')
    discount1 = Discount.create!(merchant_id: merchant.id, percentage: 0.25, quantity: 3)
    discount2 = Discount.create!(merchant_id: merchant.id, percentage: 0.50, quantity: 5)

    visit merchant_discounts_path(merchant)
    save_and_open_page
    expect(page).to have_content("Discount #1")
    expect(page).to have_content("Percentage: 25%")
    expect(page).to have_content("Quantity: 3")
    expect(page).to have_content("Discount #2")
    expect(page).to have_content("Percentage: 50%")
    expect(page).to have_content("Quantity: 5")
  end
end