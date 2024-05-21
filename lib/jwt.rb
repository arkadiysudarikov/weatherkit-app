module Jwt
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
end
