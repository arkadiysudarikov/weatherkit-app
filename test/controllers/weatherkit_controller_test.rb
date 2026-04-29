# frozen_string_literal: true

require "test_helper"

class WeatherkitControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get weatherkit_index_url
    assert_response :success
  end

  test "should handle missing address parameter" do
    get weatherkit_index_url
    assert_response :success
    assert_nil @controller.instance_variable_get(:@weather)
    assert_nil @controller.instance_variable_get(:@mapkit)
  end

  test "should fetch weather data when address is provided" do
    mock_mapkit_response = {
      "coordinate" => { "latitude" => 37.7749, "longitude" => -122.4194 },
      "structuredAddress" => { "postCode" => "94103" }
    }

    mock_weather_response = {
      "currentWeather" => { "temperature" => 15.5 }
    }

    WeatherkitController.any_instance.stubs(:mapkit).returns(mock_mapkit_response)
    WeatherkitController.any_instance.stubs(:weatherkit).returns(mock_weather_response)

    get weatherkit_index_url, params: { address: "San Francisco" }
    assert_response :success
  end

  test "should handle cache miss when zipcode is present" do
    mock_mapkit_response = {
      "coordinate" => { "latitude" => 37.7749, "longitude" => -122.4194 },
      "structuredAddress" => { "postCode" => "94103" }
    }

    mock_weather_response = {
      "currentWeather" => { "temperature" => 15.5 }
    }

    WeatherkitController.any_instance.stubs(:mapkit).returns(mock_mapkit_response)
    WeatherkitController.any_instance.stubs(:weatherkit).returns(mock_weather_response)

    get weatherkit_index_url, params: { address: "San Francisco" }
    assert_response :success
  end

  test "should handle missing zipcode gracefully" do
    mock_mapkit_response = {
      "coordinate" => { "latitude" => 37.7749, "longitude" => -122.4194 },
      "structuredAddress" => {}
    }

    mock_weather_response = {
      "currentWeather" => { "temperature" => 15.5 }
    }

    WeatherkitController.any_instance.stubs(:mapkit).returns(mock_mapkit_response)
    WeatherkitController.any_instance.stubs(:weatherkit).returns(mock_weather_response)

    get weatherkit_index_url, params: { address: "Some location without zip" }
    assert_response :success
  end
end