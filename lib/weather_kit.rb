module WeatherKit
  include Jwt

  def weatherkit(latitude, longitude)
    api_client = AppleApiClient.new

    api_client.api_call("https://weatherkit.apple.com/api/v1/weather/en/#{latitude}/#{longitude}?dataSets=currentWeather%2CforecastDaily&timezone=America%2FLos_Angeles", jwt)
  end
end

class Float
  def to_fahrenheit
    ((self * 9 / 5) + 32).round(0)
  end
end
