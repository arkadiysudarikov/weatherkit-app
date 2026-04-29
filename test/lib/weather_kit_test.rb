# frozen_string_literal: true

require "test_helper"
require_relative "../../lib/weather_kit"
require_relative "../../lib/jwt"

class WeatherKitTest < ActiveSupport::TestCase
  test "Float#to_fahrenheit converts celsius to fahrenheit" do
    # Freezing point of water: 0°C = 32°F
    assert_equal 32, 0.0.to_fahrenheit

    # Boiling point of water: 100°C = 212°F
    assert_equal 212, 100.0.to_fahrenheit

    # Room temperature: 20°C ≈ 68°F
    assert_equal 68, 20.0.to_fahrenheit

    # Negative temperature: -40°C = -40°F
    assert_equal(-40, -40.0.to_fahrenheit)
  end

  test "Float#to_fahrenheit rounds to nearest integer" do
    # 19.5°C should round to 67°F (not 67.1)
    assert_equal 67, 19.5.to_fahrenheit
  end

  test "Float#to_fahrenheit handles decimal precision" do
    # 18.3°C
    result = 18.3.to_fahrenheit
    assert_instance_of Integer, result
    assert result.between?(64, 66)
  end
end