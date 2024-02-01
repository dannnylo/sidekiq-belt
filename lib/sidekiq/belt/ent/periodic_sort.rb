# frozen_string_literal: true

require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Ent
      module PeriodicSort
        module SidekiqLoopsPeriodicSort
          def each(&block)
            @lids.map { |lid| Sidekiq::Periodic::Loop.new(lid) }.sort_by(&:klass).each(&block)
          end
        end

        def self.use!
          require("sidekiq-ent/periodic")
          require("sidekiq-ent/periodic/static_loop")

          Sidekiq::Periodic::LoopSet.prepend(Sidekiq::Belt::Ent::PeriodicSort::SidekiqLoopsPeriodicSort)
        end
      end
    end
  end
end
