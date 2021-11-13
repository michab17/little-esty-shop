require 'rails_helper'

RSpec.describe 'Merchant Discounts edit page' do
  it 'allows the merchant to edit discounts' do
    merchant = Merchant.create!(name: 'Freddy Kruger')
    discount1 = Discount.create!(merchant_id: merchant.id, percentage: 0.25, quantity: 3)

    visit merchant_discount_path(merchant, discount1)

    click_link 'Edit Discount'

    fill_in :percentage, with: 0.75
    fill_in :quantity, with: 75
    click_button 'Update'

    expect(current_path).to eq(merchant_discount_path(merchant, discount1))
    
    within "#id-#{discount1.id}" do
      expect(page).to have_content('75%')
      expect(page).to have_content('75')
      expect(page).to_not have_content('25%')
      expect(page).to_not have_content('3')
    end
  end
end