# frozen_string_literal: true

require "sidekiq"

require_relative "run_job"
require_relative "top_label"
require_relative "force_kill"

module Sidekiq
  module Belt
    module Community
      module Files
        def self.use!(options = [:all])
          Sidekiq::Belt::Community::RunJob.use! if should_use?(:run_job, options)
          Sidekiq::Belt::Community::TopLabel.use! if should_use?(:top_label, options)
          Sidekiq::Belt::Community::ForceKill.use! if should_use?(:force_kill, options)

          true
        end

        def self.should_use?(key, options)
          options.include?(:all) || options.include?(key)
        end
      end
    end
  end
end
