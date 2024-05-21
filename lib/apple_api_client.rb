module AppleApiClient
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
