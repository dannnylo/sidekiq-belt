# frozen_string_literal: true

require "sidekiq"

require_relative "periodic_pause"
require_relative "periodic_run"
require_relative "periodic_sort"

module Sidekiq
  module Belt
    module Ent
      module Files
        def self.use!(options = [:all])
          return unless Sidekiq.ent?

          Sidekiq::Belt::Ent::PeriodicPause.use! if should_use?(:periodic_pause, options)
          Sidekiq::Belt::Ent::PeriodicRun.use! if should_use?(:periodic_run, options)
          Sidekiq::Belt::Ent::PeriodicSort.use! if should_use?(:periodic_sort, options)

          true
        end

        def self.should_use?(key, options)
          options.include?(:all) || options.include?(key)
        end
      end
    end
  end
end
