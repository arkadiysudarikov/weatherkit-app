require "jwt"
require "openssl"

class WeatherkitController < ApplicationController
  include AppleApiClient

  # CACHE_EXPIRATION = 30.0.minutes
  CACHE_EXPIRATION = 10.0.seconds

  def index
    if params[:address].present?
      @token = api_call("https://maps-api.apple.com/v1/token", jwt)

      token = @token["accessToken"]

      @mapkit = api_call("https://maps-api.apple.com/v1/geocode?q=#{params[:address]}", token)

      longitude = @mapkit["results"][0]["coordinate"]["longitude"]
      latitude = @mapkit["results"][0]["coordinate"]["latitude"]

      @zipcode = @mapkit["results"][0]["structuredAddress"]["postCode"]

      @weather = if @zipcode.present?

        @cache_miss = false

        Rails.cache.fetch(@zipcode, expires_in: CACHE_EXPIRATION) do
          @cache_miss = true

          api_call("https://weatherkit.apple.com/api/v1/weather/en/#{latitude}/#{longitude}?dataSets=currentWeather%2CforecastDaily&timezone=America%2FLos_Angeles", jwt)
        end
      else
        api_call("https://weatherkit.apple.com/api/v1/weather/en/#{latitude}/#{longitude}?dataSets=currentWeather%2CforecastDaily&timezone=America%2FLos_Angeles", jwt)
      end
    end
  end

  private

  def weatherkit_params
    params.permit(:address)
  end
end
