require 'rails_helper'

RSpec.describe "Weather", type: :request do
  describe "GET /index" do
    it "should return the home page" do
      get "/"
      expect(response.status).to eq(200)
    end
  end

  describe "GET /forecast" do
    let(:params) {
      {
        street: "525 Winchester Boulevard",
        city: "San Jose",
        state: "CA",
        zip_code: "95128"
      }
    }

    context "Required params" do
      it "should require the street parameter" do
        get "/forecast", params: params.without(:street)
        expect(response.status).to eq(422)
        expect(flash[:alert]).to eq("Param is missing or the value is empty: street")
      end

      it "should require the city parameter" do
        get "/forecast", params: params.without(:city)
        expect(response.status).to eq(422)
        expect(flash[:alert]).to eq("Param is missing or the value is empty: city")
      end

      it "should require the state parameter" do
        get "/forecast", params: params.without(:state)
        expect(response.status).to eq(422)
        expect(flash[:alert]).to eq("Param is missing or the value is empty: state")
      end
      
      it "should require the zip_code parameter" do
        get "/forecast", params: params.without(:zip_code)
        expect(response.status).to eq(422)
        expect(flash[:alert]).to eq("Param is missing or the value is empty: zip_code")
      end
    end

    it "should provide an error message when the address can't be found" do
      allow_any_instance_of(OpenStreetMap::Client).to receive(:search).and_return([])
      get "/forecast", params: params
      expect(response.status).to eq(404)
      expect(flash[:alert]).to eq("The provided address could not be found. Please try again.")
    end

    it "should return the current temperature" do
      allow_any_instance_of(WeatherService).to receive(:weather_info).and_return({ "properties" => { "forecast" => "https://api.weather.gov/gridpoints/MTR/97,82/forecast" } })
      allow_any_instance_of(OpenStreetMap::Client).to receive(:search).and_return([{ "lat" => 1, "lon" => 2 }])
      allow(JSON).to receive(:parse).and_return(
        { 
          "properties" => { 
            "periods" => [
              {
                "name" => "Today",
                "temperature" => 22,
                "temperatureUnit" => "F"
              }
            ]
          } 
        }
      )

      get "/forecast", params: params
      expect(response.status).to eq(200)
      expect(assigns[:current_temperature]).to eq({ detailed_forecast: nil, temperature: "22&deg;F" })
    end

    it "should cache the current temperature" do
      allow_any_instance_of(WeatherService).to receive(:weather_info).and_return({ "properties" => { "forecast" => "https://api.weather.gov/gridpoints/MTR/97,82/forecast" } })
      allow_any_instance_of(OpenStreetMap::Client).to receive(:search).and_return([{ "lat" => 1, "lon" => 2 }])
      allow(JSON).to receive(:parse).and_return(
        { 
          "properties" => { 
            "periods" => [
              {
                "name" => "Today",
                "temperature" => 22,
                "temperatureUnit" => "F"
              }
            ]
          } 
        }
      )

      get "/forecast", params: params
      expect(response.status).to eq(200)
      expect(assigns[:current_temperature]).to eq({ detailed_forecast: nil, temperature: "22&deg;F" })
      expect(Rails.cache.read(params[:zip_code])).to eq({ detailed_forecast: nil, temperature: "22&deg;F" })
    end

    it "should use the cached version of the current temperature" do
      service_double = instance_double(WeatherService)
      allow(WeatherService).to receive(:new).and_return(service_double)
      allow(service_double).to receive(:current_temperature).and_return("")

      Rails.cache.write(params[:zip_code], { detailed_forecast: nil, temperature: "22&deg;F" })

      get "/forecast", params: params
      expect(response.status).to eq(200)
      expect(service_double).not_to have_received(:current_temperature)
    end

    it "should expire the cache of the current temperature" do
      time = nil
      params[:zip_code] = "12345"
      Timecop.freeze(32.minutes.ago) do
        allow_any_instance_of(WeatherService).to receive(:weather_info).and_return({ "properties" => { "forecast" => "https://api.weather.gov/gridpoints/MTR/97,82/forecast" } })
        allow_any_instance_of(OpenStreetMap::Client).to receive(:search).and_return([{ "lat" => 1, "lon" => 2 }])
        allow(JSON).to receive(:parse).and_return(
          { 
            "properties" => { 
              "periods" => [
                {
                  "name" => "Today",
                  "temperature" => 22,
                  "temperatureUnit" => "F"
                }
              ]
            } 
          }
        )

        get "/forecast", params: params
        expect(response.status).to eq(200)
        expect(assigns[:current_temperature]).to eq({ detailed_forecast: nil, temperature: "22&deg;F" })
        expect(Rails.cache.read(params[:zip_code])).to eq({ detailed_forecast: nil, temperature: "22&deg;F" })
      end
      
      expect(Rails.cache.read(params[:zip_code])).to be_nil

      allow_any_instance_of(WeatherService).to receive(:weather_info).and_return({ "properties" => { "forecast" => "https://api.weather.gov/gridpoints/MTR/97,82/forecast" } })
      allow_any_instance_of(OpenStreetMap::Client).to receive(:search).and_return([{ "lat" => 1, "lon" => 2 }])
      allow(JSON).to receive(:parse).and_return(
        { 
          "properties" => { 
            "periods" => [
              {
                "name" => "Today",
                "temperature" => 44,
                "temperatureUnit" => "F"
              }
            ]
          } 
        }
      )

      get "/forecast", params: params
      expect(response.status).to eq(200)
      expect(assigns[:current_temperature]).to eq({ detailed_forecast: nil, temperature: "44&deg;F" })
      expect(Rails.cache.read(params[:zip_code])).to eq({ detailed_forecast: nil, temperature: "44&deg;F" })
    end
  end
end
