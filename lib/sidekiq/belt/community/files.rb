# frozen_string_literal: true

require "sidekiq"
# require_relative "feature"

module Sidekiq
  module Belt
    module Community
      module Files
        def self.use!(_options = [:all])
          # all = options.include?(:all)
          # Sidekiq::Belt::Pro::Feature.load! if all || options.include?(:feature)

          true
        end
      end
    end
  end
end
