require 'rails_helper'

RSpec.describe "Weather", type: :request do
  describe "GET /index" do
    it "should return the home page" do
      get "/"
      expect(response.status).to eq(200)
    end
  end
  end
end
