module MapKit
  include Jwt

  def mapkit(address)
    api_client = AppleApiClient.new

    token = api_client.api_call("https://maps-api.apple.com/v1/token", jwt)["accessToken"]

    api_client.api_call("https://maps-api.apple.com/v1/geocode?q=#{address}", token)["results"].first
  end
end
