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
  end
end
