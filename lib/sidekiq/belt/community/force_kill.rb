# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/web/helpers"
require 'byebug'

module Sidekiq
  module Belt
    module Community
      module ForceKill
        def kill!
          signal("KILL")
        end

        module SidekiqForceKill
          def self.registered(app)
            app.tabs["Force Kill"] = "force_kill"

            app.get("/force_kill") do
              render(:erb, File.read(File.join(__dir__, "views/force_kill.erb")))
            end

            app.post("/force_kill/:identity/kill") do
              Sidekiq::ProcessSet[params["identity"]].kill!

              return redirect "#{root_path}force_kill"
            end
          end
        end

        def self.use!
          Sidekiq::Web.register(Sidekiq::Belt::Community::ForceKill::SidekiqForceKill)
          Sidekiq::Process.prepend(Sidekiq::Belt::Community::ForceKill)
        end
      end
    end
  end
end
