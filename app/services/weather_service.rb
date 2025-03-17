class WeatherService
  attr_reader :lat, :lon, :weather_info

  WEATHER_GOV_URL = "https://api.weather.gov/points".freeze

  def initialize(lat: nil, lon: nil)
    @lat = formatted_point(lat)
    @lon = formatted_point(lon)
  end

  def current_temperature
  end

  # Uses the latitude and longitude to retrieve information about the provided
  # address from api.weather.gov.
  # 
  # == Response Object
  # {
  #   "@context"=>[
  #     "https://geojson.org/geojson-ld/geojson-context.jsonld",
  #     {
  #       "@version"=>"1.1",
  #       "wx"=>"https://api.weather.gov/ontology#",
  #       "s"=>"https://schema.org/",
  #       "geo"=>"http://www.opengis.net/ont/geosparql#",
  #       "unit"=>"http://codes.wmo.int/common/unit/",
  #       "@vocab"=>"https://api.weather.gov/ontology#",
  #       "geometry"=>{
  #           "@id"=>"s:GeoCoordinates",
  #           "@type"=>"geo:wktLiteral"
  #       },
  #       "city"=>"s:addressLocality",
  #       "state"=>"s:addressRegion",
  #       "distance"=>{
  #         "@id"=>"s:Distance",
  #         "@type"=>"s:QuantitativeValue"
  #       },
  #       "bearing"=>{"@type"=>"s:QuantitativeValue"},
  #       "value"=>{"@id"=>"s:value"},
  #       "unitCode"=>{"@id"=>"s:unitCode", "@type"=>"@id"},
  #       "forecastOffice"=>{"@type"=>"@id"},
  #       "forecastGridData"=>{"@type"=>"@id"},
  #       "publicZone"=>{"@type"=>"@id"},
  #       "county"=>{"@type"=>"@id"}
  #     }
  #   ],
  #   "id"=>"https://api.weather.gov/points/37.3183,-121.951",
  #   "type"=>"Feature",
  #   "geometry"=>{
  #     "type"=>"Point", "coordinates"=>[-121.951, 37.3183]},
  #     "properties"=>{
  #       "@id"=>"https://api.weather.gov/points/37.3183,-121.951",
  #       "@type"=>"wx:Point",
  #       "cwa"=>"MTR",
  #       "forecastOffice"=>"https://api.weather.gov/offices/MTR",
  #       "gridId"=>"MTR",
  #       "gridX"=>97,
  #       "gridY"=>82,
  #       "forecast"=>"https://api.weather.gov/gridpoints/MTR/97,82/forecast",
  #       "forecastHourly"=>"https://api.weather.gov/gridpoints/MTR/97,82/forecast/hourly",
  #       "forecastGridData"=>"https://api.weather.gov/gridpoints/MTR/97,82",
  #       "observationStations"=>"https://api.weather.gov/gridpoints/MTR/97,82/stations",
  #       "relativeLocation"=>{
  #         "type"=>"Feature",
  #         "geometry"=>{
  #           "type"=>"Point",
  #           "coordinates"=>[-121.935678, 37.311924]
  #         },
  #         "properties"=>{
  #           "city"=>"Fruitdale",
  #           "state"=>"CA",
  #           "distance"=>{
  #             "unitCode"=>"wmoUnit:m",
  #             "value"=>1529.2739642857
  #           },
  #           "bearing"=>{
  #             "unitCode"=>"wmoUnit:degree_(angle)",
  #             "value"=>297
  #           }
  #         }
  #       },
  #       "forecastZone"=>"https://api.weather.gov/zones/forecast/CAZ513",
  #       "county"=>"https://api.weather.gov/zones/county/CAC085",
  #       "fireWeatherZone"=>"https://api.weather.gov/zones/fire/CAZ513",
  #       "timeZone"=>"America/Los_Angeles",
  #       "radarStation"=>"KMUX"
  #     }
  #   }
  # 
  # Returns the parsed JSON object from the API response body.
  def weather_info
    @weather_info ||= begin
      uri = URI("#{WEATHER_GOV_URL}/#{@lat},#{@lon}")
      res = Net::HTTP.get_response(uri)
      JSON.parse(res.body)
    end
  end

  private

  def formatted_point(point)
    # TODO: Include error handling for improperly formatted latitude and longitude.
    formatted = point.try(:to_f).try(:round, 4).try(:to_s)

    raise ArgumentError, "The lat and lon arguments are required." if formatted.nil?

    formatted
  end
end