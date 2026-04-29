# frozen_string_literal: true

# Test runner task
# Run with: rake test

namespace :test do
  desc "Run all tests"
  task :all => :environment do
    Dir.glob(Rails.root.join("test/**/*_test.rb")).each do |file|
      require file
    end
  end
end

# Rake::TestTask is defined by Rails when using Rails test infrastructure
# This provides the standard `rake test` task