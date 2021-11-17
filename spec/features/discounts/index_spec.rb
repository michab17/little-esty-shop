require 'rails_helper'

RSpec.describe 'Discounts Index Page' do
  it 'displays the next 3 upcoming holidays' do
    visit discounts_path

    within "#upcoming_holidays" do
      expect(page).to have_content('Thanksgiving Day - 2021-11-25')
      expect(page).to have_content('Christmas Day - 2021-12-24')
      expect(page).to have_content("New Years Day - 2021-12-31")
      expect(page).to_not have_content("Martin Luther King, Jr. Day")
    end
  end
end