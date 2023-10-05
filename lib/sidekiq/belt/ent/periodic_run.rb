# frozen_string_literal: true
require 'byebug'
require 'sidekiq/web/helpers'
require 'sidekiq-ent/web'
require 'sidekiq-ent/periodic'
require 'sidekiq-ent/periodic/static_loop'

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
          def self.registered(app)
            app.replace_content("/loops") do |content|
              # Add the top of the table
              content.gsub!("</th>\n    </tr>", "</th><th><%= t('Force Run') %></th></th>\n    </tr>")

              # Add the run button
              run_button = '<form action="<%= root_path %>loops/<%= loup.lid %>/run" method="post">' \
                           "<%= csrf_tag %>" \
                           '<input class="btn btn-danger btn-xs" type="submit" name="run" value="<%= t("Run now") %>" ' \
                           'data-confirm="Run the job <%= loup.klass %>? <%= t("AreYouSure") %>" />' \
                           "</form>"

              content.gsub!(
                "</td>\n      </tr>\n    <% end %>",
                "</td>\n<td>#{run_button}</td>\n      </tr>\n    <% end %>"
              )
            end

            app.post("/loops/:lid/run") do
              Sidekiq::Periodic::Loop.new(params[:lid]).run

              return redirect "#{root_path}loops"
            end
          end
        end

        def self.use!
          Sidekiq::Web.register(Sidekiq::Belt::Ent::PeriodicRun::SidekiqLoopsPeriodicRun)
          Sidekiq::Periodic::Loop.prepend(Sidekiq::Belt::Ent::PeriodicRun)
          Sidekiq::Periodic::StaticLoop.prepend(Sidekiq::Belt::Ent::PeriodicRun)
        end
      end
    end
  end
end
