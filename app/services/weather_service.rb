class WeatherService
  attr_reader :lat, :lon

  def initialize(lat: nil, lon: nil)
    @lat = formatted_point(lat)
    @lon = formatted_point(lon)
  end

  private

  def formatted_point(point)
    # TODO: Include error handling for improperly formatted latitude and longitude.
    formatted = point.try(:to_f).try(:round, 4).try(:to_s)

    raise ArgumentError, "The lat and lon arguments are required." if formatted.nil?

    formatted
  end
end