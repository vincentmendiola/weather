class WeatherService
  attr_reader :lat, :lon, :weather_info

  WEATHER_GOV_URL = "https://api.weather.gov/points".freeze

  def initialize(lat: nil, lon: nil)
    @lat = formatted_point(lat)
    @lon = formatted_point(lon)
  end

  # Retrieves the URI stored in the forecast attribute to request the current
  # temperature for the provided longitude and latitude.
  # 
  # == Caveat
  # This implementation returns the current temperature by retrieving the most
  # recent forecast periods (i.e. "Today", "This Afternoon", "Tonight"). The
  # temperature for the most recent period is returned as the current temperature.
  # 
  # == Response Object
  # {
  #   "@context"=>[
  #     "https://geojson.org/geojson-ld/geojson-context.jsonld",
  #     {
  #       "@version"=>"1.1",
  #       "wx"=>"https://api.weather.gov/ontology#",
  #       "geo"=>"http://www.opengis.net/ont/geosparql#",
  #       "unit"=>"http://codes.wmo.int/common/unit/",
  #       "@vocab"=>"https://api.weather.gov/ontology#"
  #     }
  #   ],
  #   "type"=>"Feature",
  #   "geometry"=>{
  #     "type"=>"Polygon",
  #     "coordinates"=>[
  #       [[-121.9342, 37.315],
  #       [-121.9397, 37.3369],
  #       [-121.9672, 37.3325],
  #       [-121.96170000000001, 37.3106],
  #       [-121.9342, 37.315]]
  #     ]
  #   },
  #   "properties"=>{
  #     "units"=>"us",
  #     "forecastGenerator"=>"BaselineForecastGenerator",
  #     "generatedAt"=>"2025-03-16T01:35:59+00:00",
  #     "updateTime"=>"2025-03-15T20:55:06+00:00",
  #     "validTimes"=>"2025-03-15T14:00:00+00:00/P7DT14H",
  #     "elevation"=>{
  #       "unitCode"=>"wmoUnit:m", "value"=>39.9288
  #     },
  #     "periods"=>[
  #       {
  #         "number"=>1,
  #         "name"=>"Tonight",
  #         "startTime"=>"2025-03-15T18:00:00-07:00",
  #         "endTime"=>"2025-03-16T06:00:00-07:00",
  #         "isDaytime"=>false,
  #         "temperature"=>41,
  #         "temperatureUnit"=>"F",
  #         "temperatureTrend"=>"",
  #         "probabilityOfPrecipitation"=>{
  #           "unitCode"=>"wmoUnit:percent",
  #           "value"=>nil
  #         },
  #         "windSpeed"=>"2 to 6 mph",
  #         "windDirection"=>"SSE",
  #         "icon"=>"https://api.weather.gov/icons/land/night/few?size=medium",
  #         "shortForecast"=>"Mostly Clear",
  #         "detailedForecast"=>"Mostly clear, with a low around 41. South southeast wind 2 to 6 mph."},
  #       {
  #         "number"=>2,
  #         "name"=>"Sunday",
  #         "startTime"=>"2025-03-16T06:00:00-07:00",
  #         "endTime"=>"2025-03-16T18:00:00-07:00",
  #         "isDaytime"=>true,
  #         "temperature"=>63,
  #         "temperatureUnit"=>"F",
  #         "temperatureTrend"=>"",
  #         "probabilityOfPrecipitation"=>{
  #           "unitCode"=>"wmoUnit:percent",
  #           "value"=>80
  #         },
  #         "windSpeed"=>"6 to 22 mph",
  #         "windDirection"=>"S",
  #         "icon"=>"https://api.weather.gov/icons/land/day/wind_bkn/rain,80?size=medium",
  #         "shortForecast"=>"Partly Sunny then Light Rain",
  #         "detailedForecast"=>"Rain after 5pm. Partly sunny. High near 63, with temperatures falling to around 61 in the afternoon. South wind 6 to 22 mph, with gusts as high as 32 mph. Chance of precipitation is 80%. New rainfall amounts less than a tenth of an inch possible."},
  #         {
  #           "number"=>3,
  #           "name"=>"Sunday Night",
  #           "startTime"=>"2025-03-16T18:00:00-07:00",
  #           "endTime"=>"2025-03-17T06:00:00-07:00",
  #           "isDaytime"=>false,
  #           "temperature"=>47,
  #           "temperatureUnit"=>"F",
  #           "temperatureTrend"=>"",
  #           "probabilityOfPrecipitation"=>{
  #             "unitCode"=>"wmoUnit:percent",
  #             "value"=>100
  #           },
  #           "windSpeed"=>"6 to 20 mph",
  #           "windDirection"=>"S",
  #           "icon"=>"https://api.weather.gov/icons/land/night/rain,100?size=medium",
  #           "shortForecast"=>"Rain",
  #           "detailedForecast"=>"Rain. Cloudy. Low around 47, with temperatures rising to around 49 overnight. South wind 6 to 20 mph, with gusts as high as 31 mph. Chance of precipitation is 100%. New rainfall amounts between a quarter and half of an inch possible."},
  #           {
  #             "number"=>4,
  #             "name"=>"Monday",
  #             "startTime"=>"2025-03-17T06:00:00-07:00",
  #             "endTime"=>"2025-03-17T18:00:00-07:00",
  #             "isDaytime"=>true,
  #             "temperature"=>59,
  #             "temperatureUnit"=>"F",
  #             "temperatureTrend"=>"",
  #             "probabilityOfPrecipitation"=>{
  #               "unitCode"=>"wmoUnit:percent",
  #               "value"=>70
  #             },
  #             "windSpeed"=>"6 to 16 mph",
  #             "windDirection"=>"WSW",
  #             "icon"=>"https://api.weather.gov/icons/land/day/rain,70/rain,40?size=medium",
  #             "shortForecast"=>"Light Rain Likely",
  #             "detailedForecast"=>"Rain likely before 5pm. Partly sunny, with a high near 59. West southwest wind 6 to 16 mph, with gusts as high as 30 mph. Chance of precipitation is 70%. New rainfall amounts less than a tenth of an inch possible."},
  #             {
  #               "number"=>5,
  #               "name"=>"Monday Night",
  #               "startTime"=>"2025-03-17T18:00:00-07:00",
  #               "endTime"=>"2025-03-18T06:00:00-07:00",
  #               "isDaytime"=>false,
  #               "temperature"=>37,
  #               "temperatureUnit"=>"F",
  #               "temperatureTrend"=>"",
  #               "probabilityOfPrecipitation"=>{
  #                 "unitCode"=>"wmoUnit:percent",
  #                 "value"=>nil
  #               },
  #               "windSpeed"=>"5 to 16 mph",
  #               "windDirection"=>"NW",
  #               "icon"=>"https://api.weather.gov/icons/land/night/few?size=medium",
  #               "shortForecast"=>"Mostly Clear",
  #               "detailedForecast"=>"Mostly clear, with a low around 37. Northwest wind 5 to 16 mph, with gusts as high as 30 mph."
  #             }
  #           }
  #         }
  #       }
  #     ]
  #   }
  # }  
  # 
  # Returns a Hash with the temperature formatted for HTML (e.g. "22&deg;F")
  # and the detailed forecast (e.g. "A chance of rain showers. Mostly cloudy, 
  # with a low around 37.").
  def current_temperature
    forecast_uri = weather_info.dig("properties", "forecast")

    if forecast_uri.present?
      uri = URI(forecast_uri)
      res = Net::HTTP.get_response(uri)
      results = JSON.parse(res.body)
      periods = results.dig("properties", "periods")

      if periods.present?
        current_info = periods.select { |day| ["Today", "This Afternoon", "Tonight"].include?(day["name"]) }.first

        return {
          temperature: "#{current_info['temperature']}&deg;#{current_info['temperatureUnit']}",
          detailed_forecast: current_info["detailedForecast"]
        }
      else
        raise StandardError, "Unable to find the current temperature for the provided location."
      end
    else
      raise StandardError, "Unable to process the request to api.weather.gov."
    end
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