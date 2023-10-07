# frozen_string_literal: true

require "sidekiq-ent/periodic"
require "sidekiq-ent/periodic/static_loop"

module Sidekiq
  module Belt
    module Ent
      module PeriodicPause
        # def run
        #   Module.const_get(klass).perform_async
        # end

        def self.use!
          Sidekiq::Periodic::Loop.prepend(Sidekiq::Belt::Ent::PeriodicPause)
          Sidekiq::Periodic::StaticLoop.prepend(Sidekiq::Belt::Ent::PeriodicPause)
        end
      end
    end
  end
end
