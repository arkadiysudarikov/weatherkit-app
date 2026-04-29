# frozen_string_literal: true

require "test_helper"
require_relative "../../lib/map_kit"
require_relative "../../lib/jwt"

class MapKitTest < ActiveSupport::TestCase
  def setup
    @test_class = Class.new { include MapKit }
    @mapkit_instance = @test_class.new
  end

  test "mapkit returns latitude and longitude from address" do
    mock_token_response = { "accessToken" => "mock-token-123" }
    mock_geocode_response = {
      "results" => [
        {
          "coordinate" => { "latitude" => 37.7749, "longitude" => -122.4194 },
          "structuredAddress" => { "postCode" => "94103" }
        }
      ]
    }

    api_client_mock = mock("AppleApiClient")
    api_client_mock.stubs(:api_call).with(
      "https://maps-api.apple.com/v1/token",
      anything
    ).returns(mock_token_response)
    api_client_mock.stubs(:api_call).with(
      "https://maps-api.apple.com/v1/geocode?q=San Francisco",
      "mock-token-123"
    ).returns(mock_geocode_response)

    AppleApiClient.stubs(:new).returns(api_client_mock)

    result = @mapkit_instance.mapkit("San Francisco")

    assert_equal 37.7749, result["coordinate"]["latitude"]
    assert_equal(-122.4194, result["coordinate"]["longitude"])
    assert_equal "94103", result["structuredAddress"]["postCode"]
  end

  test "mapkit returns first result from multiple results" do
    mock_token_response = { "accessToken" => "mock-token-456" }
    mock_geocode_response = {
      "results" => [
        { "name" => "First Result", "coordinate" => { "latitude" => 1.0, "longitude" => 1.0 } },
        { "name" => "Second Result", "coordinate" => { "latitude" => 2.0, "longitude" => 2.0 } }
      ]
    }

    api_client_mock = mock("AppleApiClient")
    api_client_mock.stubs(:api_call).with(
      "https://maps-api.apple.com/v1/token",
      anything
    ).returns(mock_token_response)
    api_client_mock.stubs(:api_call).with(
      "https://maps-api.apple.com/v1/geocode?q=Some Address",
      "mock-token-456"
    ).returns(mock_geocode_response)

    AppleApiClient.stubs(:new).returns(api_client_mock)

    result = @mapkit_instance.mapkit("Some Address")

    assert_equal 1.0, result["coordinate"]["latitude"]
  end
end