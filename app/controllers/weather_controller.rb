class WeatherController < ApplicationController
  after_action -> { flash.discard }

  def index
  end

  def forecast
    begin
      weather_params
    rescue ActionController::ParameterMissing => e
      first_letter = e.message.first.upcase
      message_remainder = e.message[1..e.message.size]
      flash[:alert] = first_letter + message_remainder

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
