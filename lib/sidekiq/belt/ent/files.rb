# frozen_string_literal: true

require "sidekiq"

require_relative "periodic_pause"
require_relative "periodic_run"

module Sidekiq
  module Belt
    module Ent
      module Files
        def self.use!(options = [:all])
          return unless Sidekiq.ent?

          all = options.include?(:all)

          Sidekiq::Belt::Ent::PeriodicPause.use! if all || options.include?(:periodic_pause)
          Sidekiq::Belt::Ent::PeriodicRun.use! if all || options.include?(:periodic_run)

          true
        end
      end
    end
  end
end
