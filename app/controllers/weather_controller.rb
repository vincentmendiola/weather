class WeatherController < ApplicationController
  after_action -> { flash.discard }

  def index
  end

  # Uses the OpenStreetMap and WeatherService to retrieve the weather forecast.
  # 
  # == OpenStreetMap Response Object
  # {
  #   "place_id"=>297206296,
  #   "licence"=>
  #   "Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright",
  #   "osm_type"=>"relation",
  #   "osm_id"=>13734358,
  #   "lat"=>"37.3182932",
  #   "lon"=>"-121.9509885981505",
  #   "class"=>"historic",
  #   "type"=>"heritage",
  #   "place_rank"=>30,
  #   "importance"=>0.405994309706842,
  #   "addresstype"=>"historic",
  #   "name"=>"Winchester Mystery House",
  #   "display_name"=>
  #   "Winchester Mystery House, 525, Winchester Boulevard, San Jose, Santa Clara County, California, 95128, United States",
  #   "address"=>{
  #     "historic"=>"Winchester Mystery House",
  #     "house_number"=>"525",
  #     "road"=>"Winchester Boulevard",
  #     "city"=>"San Jose",
  #     "county"=>"Santa Clara County",
  #     "state"=>"California",
  #     "ISO3166-2-lvl4"=>"US-CA",
  #     "postcode"=>"95128",
  #     "country"=>"United States",
  #     "country_code"=>"us"
  #   },
  #   "boundingbox"=>[
  #     "37.3178410",
  #     "37.3187484",
  #     "-121.9517206",
  #     "-121.9506855"
  #   ]
  # }
  def forecast
    begin
      client = OpenStreetMap::Client.new
      address_result = client.search(q: weather_params.join(" "),
                                      format: 'json',
                                      addressdetails: '1',
                                      accept_language: 'en'
                                    ).try(:first)

      if address_result.present?
        lat = address_result["lat"]
        lon = address_result["lon"]

        weather_service = WeatherService.new(lat: lat, lon: lon)

        @current_temperature = weather_service.current_temperature
        
        # TODO: Add Caching
      else
        flash[:alert] = "The provided address could not be found. Please try again."

        render status: 404
      end
    rescue ActionController::ParameterMissing => e
      first_letter = e.message.first.upcase
      message_remainder = e.message[1..e.message.size]
      flash[:alert] = first_letter + message_remainder

      render status: 422
    rescue StandardError => e
      flash[:alert] = e.message

      render status: 422
    end
  end

  private

  def weather_params
    params.require(
      [
        :street,
        :city,
        :state,
        :zip_code
      ]
    )
  end
end
