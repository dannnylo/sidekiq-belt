# frozen_string_literal: true

require "sidekiq"

require_relative "belt/version"

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
  end
end
