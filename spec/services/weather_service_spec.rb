require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:lat) { 37.3182932 }
  let(:lon) { -121.9509885981505 }

  it "should require the lat and lon arguments" do
    expect {
      described_class.new
    }.to raise_error(ArgumentError, "The lat and lon arguments are required.")
  end

  it "should get the info for the provided latitude and longitude" do
    allow_any_instance_of(described_class).to receive(:weather_info).and_return({})
    weather_service = described_class.new(lat: lat, lon: lon)
    expect(weather_service.weather_info).to eq({})
  end

  it "should raise an exception when the weather_info returns an empty Hash" do
    allow_any_instance_of(described_class).to receive(:weather_info).and_return({})
    weather_service = described_class.new(lat: lat, lon: lon)
    expect {
      weather_service.current_temperature
    }.to raise_error(StandardError, "Unable to process the request to api.weather.gov.")
  end

  it "should raise an exception when the api.weather.gov forecast endpoint returns an empty Hash" do
    allow_any_instance_of(described_class).to receive(:weather_info).and_return({ "properties" => { "forecast" => {} } })
    allow_any_instance_of(JSON).to receive(:parse).and_return({})
    weather_service = described_class.new(lat: lat, lon: lon)
    expect {
      weather_service.current_temperature
    }.to raise_error(StandardError, "Unable to process the request to api.weather.gov.")
  end

  it "should return the current temperature formatted for the view" do
    allow_any_instance_of(described_class).to receive(:weather_info).and_return({ "properties" => { "forecast" => "https://api.weather.gov/gridpoints/MTR/97,82/forecast" } })
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
    weather_service = described_class.new(lat: lat, lon: lon)
    expect(weather_service.current_temperature).to eq({ detailed_forecast: nil, temperature: "22&deg;F" })
  end
end
