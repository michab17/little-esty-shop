class DiscountsController < ApplicationController
  def index
    @holidays = ApplicationController.holiday_list
  end
end