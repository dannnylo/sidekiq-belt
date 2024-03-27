# frozen_string_literal: true

require "sidekiq"

require_relative "run_job"

module Sidekiq
  module Belt
    module Community
      module Files
        def self.use!(options = [:all])
          Sidekiq::Belt::Community::RunJob.use! if should_use?(:run_job, options)

          true
        end

        def self.should_use?(key, options)
          options.include?(:all) || options.include?(key)
        end
      end
    end
  end
end
