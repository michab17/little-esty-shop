class ApplicationController < ActionController::Base
  def self.holiday_list
    HolidayFacade.holidays.holiday_list
  end
end
