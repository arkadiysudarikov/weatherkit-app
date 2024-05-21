module WeatherKit
  include Jwt
  include AppleApiClient

  def weatherkit(latitude, longitude)
    api_call("https://weatherkit.apple.com/api/v1/weather/en/#{latitude}/#{longitude}?dataSets=currentWeather%2CforecastDaily&timezone=America%2FLos_Angeles", jwt)
  end
end
