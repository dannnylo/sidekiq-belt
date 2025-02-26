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

        def self.dynamic_type?(arg, type)
          return false unless arg.is_a?(Hash)

          arg[:dynamic].to_s == type
        end

        def self.run_job(job_id, extra_args = {})
          job = Sidekiq::Belt.config.run_jobs[job_id.to_i]
          job.transform_keys(&:to_sym)

          args = job.fetch(:args, [])

          new_args = []
          args.each_with_index do |arg, i|
            if dynamic_type?(arg, "text")
              new_args[i] = extra_args.shift
            elsif dynamic_type?(arg, "integer")
              new_args[i] = extra_args.shift.to_i
            elsif dynamic_type?(arg, "boolean")
              new_args[i] = extra_args.shift == "true"
            elsif dynamic_type?(arg, "enum")
              new_args[i] = extra_args.shift
            else
              new_args << arg
            end
          end

          Module.const_get(job[:class]).perform_async(*new_args)
        end

        module SidekiqRunJob
          def self.registered(app)
            app.get("/run_jobs") do
              @jobs = Sidekiq::Belt::Community::RunJob.list_grouped_jobs

              render(:erb, File.read(File.join(__dir__, "views/run_jobs.erb")))
            end

            app.post("/run_jobs/:rjid/run") do
              args = url_params("args")

              Sidekiq::Belt::Community::RunJob.run_job(route_params(:rjid).to_i, args)

              return redirect "#{root_path}run_jobs"
            end
          end
        end

        def self.use!
          Sidekiq::Web.configure do |cfg|
            cfg.register(Sidekiq::Belt::Community::RunJob::SidekiqRunJob, name: "run_jobs", tab: "Run Jobs",
                                                                          index: "run_jobs")
          end
        end
      end
    end
  end
end
