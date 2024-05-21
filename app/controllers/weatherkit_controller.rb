require "jwt"
require "openssl"

class WeatherkitController < ApplicationController
  include MapKit
  include WeatherKit

  # CACHE_EXPIRATION = 30.0.minutes
  CACHE_EXPIRATION = 10.0.seconds

  def index
    if params[:address].present?
      @mapkit = mapkit

      latitude = @mapkit["results"][0]["coordinate"]["latitude"]
      longitude = @mapkit["results"][0]["coordinate"]["longitude"]

      @zipcode = @mapkit["results"][0]["structuredAddress"]["postCode"]

      @weather = if @zipcode.present?

        @cache_miss = false

        Rails.cache.fetch(@zipcode, expires_in: CACHE_EXPIRATION) do
          @cache_miss = true

          weatherkit(latitude, longitude)
        end
      else
        weatherkit(latitude, longitude)
      end
    end
  end

  private

  def weatherkit_params
    params.permit(:address)
  end
end
