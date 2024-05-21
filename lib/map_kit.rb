module MapKit
  include Jwt
  include AppleApiClient

  def mapkit
    @token = api_call("https://maps-api.apple.com/v1/token", jwt)

    token = @token["accessToken"]

    api_call("https://maps-api.apple.com/v1/geocode?q=#{params[:address]}", token)
  end
end
