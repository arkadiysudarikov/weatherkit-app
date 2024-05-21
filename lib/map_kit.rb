module MapKit
  include Jwt

  def mapkit
    api_client = AppleApiClient.new

    @token = api_client.api_call("https://maps-api.apple.com/v1/token", jwt)

    token = @token["accessToken"]

    api_client.api_call("https://maps-api.apple.com/v1/geocode?q=#{params[:address]}", token)
  end
end
