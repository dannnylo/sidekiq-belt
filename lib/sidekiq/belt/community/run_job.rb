# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Community
      module RunJob
        def self.list_grouped_jobs
          jobs = {}
          Sidekiq::Belt.config.run_jobs.each_with_index do |job, i|
            job.transform_keys(&:to_sym)
            job[:id] = i

            jobs[job[:group].to_s] ||= []
            jobs[job[:group].to_s] << job
          end

          jobs
        end

        def self.run_job(job_id)
          job = Sidekiq::Belt.config.run_jobs[job_id.to_i]
          job.transform_keys(&:to_sym)

          Module.const_get(job[:class]).perform_async(*job.fetch(:args, []))
        end

        module SidekiqRunJob
          def self.registered(app)
            app.tabs["Run Jobs"] = "run_jobs"

            app.get("/run_jobs") do
              @jobs = Sidekiq::Belt::Community::RunJob.list_grouped_jobs

              render(:erb, File.read(File.join(__dir__, "views/run_jobs.erb")))
            end

            app.post("/run_jobs/:rjid/run") do
              Sidekiq::Belt::Community::RunJob.run_job(params[:rjid].to_i)

              return redirect "#{root_path}run_jobs"
            end
          end
        end

        def self.use!
          Sidekiq::Web.register(Sidekiq::Belt::Community::RunJob::SidekiqRunJob)
        end
      end
    end
  end
end
