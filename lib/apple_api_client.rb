module AppleApiClient
  def jwt
    private_key = Rails.application.credentials.apple.private_key
    team_id = Rails.application.credentials.apple.team_id
    key_id = Rails.application.credentials.apple.key_id
    service_id = Rails.application.credentials.apple.service_id

    JWT.encode({
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
  end

  def api_call(url, token)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start

    request = Net::HTTP::Get.new(uri.request_uri)
    request.add_field("Authorization", "Bearer #{token}")

    response = http.request(request)

    JSON.parse(response.body)
  end
end
