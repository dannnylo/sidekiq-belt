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
          FORCE_RUN_BUTTON_ERB = <<~HTML
            <form action="<%= root_path %>loops/<%= loup.lid %>/run" method="post">
              <%= csrf_tag %>
              <input class="btn btn-danger" type="submit" name="run" value="<%= t('Run now') %>"
                data-confirm="Run the job <%= loup.klass %>? <%= t('AreYouSure') %>" />
            </form>
          HTML

          FORCE_RUN_SINGLE_PAGE_ERB = <<~HTML
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
          HTML

          def self.registered(app)
            app.replace_content("/loops") do |content|
              # Add the top of the table
              content.gsub!("</th>\n    </tr>", "</th><th><%= t('Force Run') %></th></th>\n    </tr>")

              # Add the run button
              content.gsub!(
                "</td>\n      </tr>\n    <% end %>",
                "</td>\n<td>#{FORCE_RUN_BUTTON_ERB}</td>\n      </tr>\n    <% end %>"
              )
            end

            app.replace_content("/loops/:lid") do |content|
              i = 0

              content.gsub!("</tbody>") do |match|
                if i.zero?
                  i += 1

                  FORCE_RUN_SINGLE_PAGE_ERB
                else
                  match
                end
              end
            end

            app.post("/loops/:lid/run") do
              Sidekiq::Periodic::Loop.new(params[:lid]).run

              return redirect "#{root_path}loops"
            end
          end
        end

        def self.use!
          require("sidekiq-ent/web")
          require("sidekiq-ent/periodic")
          require("sidekiq-ent/periodic/static_loop")

          Sidekiq::Web.register(Sidekiq::Belt::Ent::PeriodicRun::SidekiqLoopsPeriodicRun)
          Sidekiq::Periodic::Loop.prepend(Sidekiq::Belt::Ent::PeriodicRun)
          Sidekiq::Periodic::StaticLoop.prepend(Sidekiq::Belt::Ent::PeriodicRun)
        end
      end
    end
  end
end
