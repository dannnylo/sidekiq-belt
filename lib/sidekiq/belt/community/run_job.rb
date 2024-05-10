# frozen_string_literal: true

require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Community
      module RunJob
        module SidekiqRunJob
          def self.registered(app)
            app.tabs["Run Jobs"] = "run_jobs"

            app.get("/run_jobs") do
              @jobs = {}

              jobs = Sidekiq::Config::DEFAULTS.fetch(:run_jobs, [])

              jobs.each_with_index do |job, i|
                job[:id] = i

                @jobs[job[:group]] ||= []
                @jobs[job[:group]] << job
              end

              render(:erb, File.read(File.join(__dir__, "views/run_jobs.erb")))
            end

            app.post("/run_jobs/:rjid/run") do
              jobs = Sidekiq::Config::DEFAULTS.fetch(:run_jobs, [])
              job = jobs[params[:rjid].to_i].symbolize_keys

              Module.const_get(job[:klass]).perform_async(*job[:args])

              return redirect "#{root_path}run_jobs"
            end
          end
        end

        def self.register(jobs)
          Sidekiq::Config::DEFAULTS[:run_jobs] = jobs
        end

        def self.use!
          require("sidekiq-ent/web")

          Sidekiq::Web.register(Sidekiq::Belt::Community::RunJob::SidekiqRunJob)
        end
      end
    end
  end
end
