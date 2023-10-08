# frozen_string_literal: true

require "sidekiq"

# require_relative "feature"

module Sidekiq
  module Belt
    module Pro
      module Files
        def self.use!(_options = [:all])
          return unless Sidekiq.pro?

          # all = options.include?(:all)
          # Sidekiq::Belt::Pro::Feature.load! if all || options.include?(:feature)
        end
      end
    end
  end
end
