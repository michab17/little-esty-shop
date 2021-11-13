class HolidayService
  def self.holidays
    connection("/api/v2/NextPublicHolidays/US")
  end

  def self.connection(url)
    response = Faraday.get("https://date.nager.at#{url}")
    output = JSON.parse(response.body, symbolize_names: true)
  end
end