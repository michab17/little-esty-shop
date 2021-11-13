require 'rails_helper'

RSpec.describe 'Discounts Index Page' do
  it 'displays the next 3 upcoming holidays' do
    visit discounts_path

    within "#upcoming_holidays" do
      expect(page).to have_content('Thanksgiving Day')
      expect(page).to have_content('Christmas Day')
      expect(page).to have_content("New Year's Day")
      expect(page).to_not have_content("Martin Luther King, Jr. Day")
    end
  end
end