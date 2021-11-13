class HolidayFacade
  def self.holidays
    holidays = HolidayService.holidays
    HolidayList.new(holidays)
  end
end