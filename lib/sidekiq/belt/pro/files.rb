# frozen_string_literal: true

require "sidekiq"

require_relative "failed_batch_remove"
require_relative 'force_batch_callback'

module Sidekiq
  module Belt
    module Pro
      module Files
        def self.use!(options = [:all])
          return unless Sidekiq.pro?

          all = options.include?(:all)

          Sidekiq::Belt::Pro::FailedBatchRemove.use! if all || options.include?(:failed_batch_remove)
          Sidekiq::Belt::Pro::ForceBatchCallback.use! if all || options.include?(:force_batch_callback)

          true
        end
      end
    end
  end
end
