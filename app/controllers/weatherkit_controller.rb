require "jwt"
require "openssl"

class WeatherkitController < ApplicationController
  # CACHE_EXPIRATION = 30.0.minutes
  CACHE_EXPIRATION = 10.0.seconds

  def index
    if params[:address].present?
      private_key = Rails.application.credentials.apple.private_key
      team_id = Rails.application.credentials.apple.team_id
      key_id = Rails.application.credentials.apple.key_id
      service_id = Rails.application.credentials.apple.service_id

      Rails.logger.debug "private_key: #{private_key}"
      Rails.logger.debug "team_id: #{team_id}"
      Rails.logger.debug "key_id: #{key_id}"
      Rails.logger.debug "service_id: #{service_id}"


      jwt = JWT.encode({
        iss: team_id,
        iat: Time.now.to_i,
        exp: 30.minutes.from_now.to_i,
        sub: service_id
      },
      OpenSSL::PKey::EC.new("-----BEGIN PRIVATE KEY-----\n#{private_key}\n-----END PRIVATE KEY-----"),
      "ES256",
      {
        kid: key_id,
        id: "#{team_id}.#{service_id}"
      })


      Rails.logger.debug "jwt: #{jwt.inspect}"

      @token = api_call("https://maps-api.apple.com/v1/token", jwt)

      token = @token["accessToken"]

      @mapkit = api_call("https://maps-api.apple.com/v1/geocode?q=#{params[:address]}", token)

      longitude = @mapkit["results"][0]["coordinate"]["longitude"]
      latitude = @mapkit["results"][0]["coordinate"]["latitude"]





      @zipcode = @mapkit["results"][0]["structuredAddress"]["postCode"]

      Rails.logger.info "zipcode: #{@zipcode}"

      @weather = if @zipcode.present?

        @cache_miss = false

        Rails.cache.fetch(@zipcode, expires_in: CACHE_EXPIRATION) do
          @cache_miss = true

          api_call("https://weatherkit.apple.com/api/v1/weather/en/#{latitude}/#{longitude}?dataSets=currentWeather%2CforecastDaily&timezone=America%2FLos_Angeles", jwt)
        end


      else
        api_call("https://weatherkit.apple.com/api/v1/weather/en/#{latitude}/#{longitude}?dataSets=currentWeather%2CforecastDaily&timezone=America%2FLos_Angeles", jwt)
      end






      Rails.logger.info "cache_miss: #{@cache_miss}"




    end
  end

  private

  def weatherkit_params
    params.permit(:address)
  end

  def api_call(url, token)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true

    http.start

    request = Net::HTTP::Get.new(uri.request_uri)

    request.add_field("Authorization", "Bearer #{token}")

    response = http.request(request)

    Rails.logger.info "response: #{response.body}"

    JSON.parse(response.body)
  end
end
