# frozen_string_literal: true

require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Community
      module RunJob
        def run
          args = begin
            JSON.parse(options)["args"]
          rescue StandardError
            {}
          end

          Module.const_get(klass).perform_async(*args)
        end

        module SidekiqRunJob
          def self.registered(app)
            app.tabs["Run Jobs"] = "run_jobs"

            app.get("/run_jobs") do
              @jobs = [
                { klass: "AClass", args: [1, 2, 3] }
              ]

              render(:erb, File.read(File.join(__dir__, "views/run_jobs.erb")))
            end

            app.post("/run_jobs/:rjid/run") do

              #
              return redirect "#{root_path}run_jobs"
            end
          end
        end

        def self.use!
          require("sidekiq-ent/web")

          Sidekiq::Web.register(Sidekiq::Belt::Ent::PeriodicRun::SidekiqRunJob)
        end
      end
    end
  end
end
