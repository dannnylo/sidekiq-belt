# frozen_string_literal: true

require "simplecov"

SimpleCov.start :test_frameworks do
  enable_coverage :branch

  # minimum_coverage line: 100, branch: 85
end

require "sidekiq/belt"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
