require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:lat) { 37.3182932 }
  let(:lon) { -121.9509885981505 }

  it "should require the lat and lon arguments" do
    expect {
      described_class.new
    }.to raise_error(ArgumentError, "The lat and lon arguments are required.")
  end
end
