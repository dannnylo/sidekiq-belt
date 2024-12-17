# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Community
      module ForceKill
        def kill!
          signal("KILL")
        end

        module SidekiqForceKill
          def self.registered(app)
            app.replace_content("/busy") do |content|
              content.gsub!("<%= t('Stop') %></button>") do
                "<%= t('Stop') %></button>" \
                  "<% if process.stopping? %>" \
                  "<a href=\"<%= root_path %>/force_kill/<%= process['identity'] %>/kill\" " \
                  "class=\"btn btn-xs btn-danger\" data-confirm=\"<%= t('AreYouSure') %>\">" \
                  "<%= t('Kill') %></a>" \
                  "<% end %>"
              end
            end

            app.get("/force_kill/:identity/kill") do
              process = Sidekiq::ProcessSet[route_params(:identity)]

              if process
                process.stop!
                process.kill!
              end

              return redirect "#{root_path}busy"
            end
          end
        end

        def self.use!
          Sidekiq::Web.configure do |cfg|
            cfg.register(Sidekiq::Belt::Community::ForceKill::SidekiqForceKill, name: 'force_kill', tab: nil, index: nil)
          end
          Sidekiq::Process.prepend(Sidekiq::Belt::Community::ForceKill)
        end
      end
    end
  end
end
