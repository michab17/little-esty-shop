class HolidayList
  def initialize(data)
    @data = data
  end

  def holiday_list
    @data[0..2].map do |holiday|
      holiday[:name]
    end
  end
end