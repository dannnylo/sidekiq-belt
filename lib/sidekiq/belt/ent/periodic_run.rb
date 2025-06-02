# frozen_string_literal: true

require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Ent
      module PeriodicRun
        def run
          args = begin
            JSON.parse(options)["args"]
          rescue StandardError
            {}
          end

          Module.const_get(klass).perform_async(*args)
        end

        module SidekiqLoopsPeriodicRun
          FORCE_RUN_BUTTON = <<~ERB
            name="enqueue" data-confirm="Enqueue the job <%= loup.klass %>? <%= t('AreYouSure') %>"
          ERB

          FORCE_RUN_SINGLE_PAGE = <<~ERB
                <tr>
                <th><%= t('Force Run') %></th>
                <td>
                  <form action="<%= root_path %>loops/<%= @loop.lid %>/run" method="post">
                    <%= csrf_tag %>
                    <input class="btn btn-danger" type="submit" name="run" value="<%= t('Run now') %>"
                      data-confirm="Run the job <%= @loop.klass %>? <%= t('AreYouSure') %>" />
                  </form>
                </td>
              </tr>
            </tbody>
          ERB

          def self.registered(app)
            app.replace_content("/loops") do |content|
              content.gsub!("name=\"enqueue\"", FORCE_RUN_BUTTON)
            end

            app.replace_content("/loops/:lid") do |content|
              i = 0

              content.gsub!("</tbody>") do |match|
                if i.zero?
                  i += 1

                  FORCE_RUN_SINGLE_PAGE
                else
                  match
                end
              end
            end

            app.post("/loops/:lid/run") do
              Sidekiq::Periodic::Loop.new(route_params(:lid)).run

              return redirect "#{root_path}loops"
            end
          end
        end

        def self.use!
          require("sidekiq-ent/web")
          require("sidekiq-ent/periodic")
          require("sidekiq-ent/periodic/static_loop")

          Sidekiq::Web.configure do |cfg|
            cfg.register(Sidekiq::Belt::Ent::PeriodicRun::SidekiqLoopsPeriodicRun, name: "periodic_run", tab: nil,
                                                                                   index: nil)
          end
          Sidekiq::Periodic::Loop.prepend(Sidekiq::Belt::Ent::PeriodicRun)
          Sidekiq::Periodic::StaticLoop.prepend(Sidekiq::Belt::Ent::PeriodicRun)
        end
      end
    end
  end
end
