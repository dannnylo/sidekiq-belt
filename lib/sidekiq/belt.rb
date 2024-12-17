# frozen_string_literal: true

require "sidekiq"

require_relative "belt/version"
require "sidekiq/web"
require_relative "web_action_helper"
require_relative "web_router_helper"

require_relative("belt/community/files")
require_relative("belt/ent/files")
require_relative("belt/pro/files")

module Sidekiq
  module Belt
    class Error < StandardError; end

    def self.use!(options = [:all])
      Sidekiq::Belt::Community::Files.use!(options)
      Sidekiq::Belt::Pro::Files.use!(options)
      Sidekiq::Belt::Ent::Files.use!(options)
    end

    def self.configure
      yield config
    end

    def self.config
      @config ||= Struct.new(:run_jobs, :top_label).new([], {})
    end

    def self.env
      (Sidekiq.default_configuration[:environment] ||
        ENV["APP_ENV"] ||
        ENV["RAILS_ENV"] ||
        ENV["RACK_ENV"] ||
        "development").to_sym
    end
  end
end
