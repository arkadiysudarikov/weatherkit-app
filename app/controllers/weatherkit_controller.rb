class WeatherkitController < ApplicationController
  include MapKit
  include WeatherKit

  CACHE_EXPIRATION = 30.0.minutes

  def index
    if params[:address].present?
      @mapkit = mapkit(params[:address])

      (latitude, longitude) = @mapkit["coordinate"]["latitude"], @mapkit["coordinate"]["longitude"]

      @zipcode = @mapkit["structuredAddress"]["postCode"]

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
