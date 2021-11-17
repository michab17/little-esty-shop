class HolidayList
  def initialize(data)
    @data = data
  end

  def holiday_list
    holiday_information = Hash.new
    @data[0..2].map do |holiday|
      holiday_information[holiday[:name]] = holiday[:date]
    end
    holiday_information
  end
end