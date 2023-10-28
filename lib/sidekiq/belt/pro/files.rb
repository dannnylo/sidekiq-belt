# frozen_string_literal: true

require "sidekiq"

require_relative "failed_batch_remove"

module Sidekiq
  module Belt
    module Pro
      module Files
        def self.use!(options = [:all])
          return unless Sidekiq.pro?

          all = options.include?(:all)

          Sidekiq::Belt::Pro::FailedBatchRemove.use! if all || options.include?(:failed_batch_remove)

          true
        end
      end
    end
  end
end
