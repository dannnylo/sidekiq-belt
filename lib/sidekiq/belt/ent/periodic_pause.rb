# frozen_string_literal: true

require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Ent
      module PeriodicPause
        def paused?
          Sidekiq.redis { |r| r.hget("PeriodicPaused", @lid.to_s) }.to_s == "p"
        end

        def pause!
          Sidekiq.redis { |r| r.hset("PeriodicPaused", @lid.to_s, "p") }
        end

        def unpause!
          Sidekiq.redis { |r| r.hdel("PeriodicPaused", @lid.to_s) }
        end

        module SidekiqLoopsPeriodicPause
          PAUSE_BUTTON = <<~ERB
            <form action="<%= root_path %>loops/<%= loup.lid %>/pause" method="post">
              <%= csrf_tag %>
              <input class="btn btn-danger btn-pause" type="submit" name="pause" value="<%= t('Pause') %>"
                data-confirm="Pause the job <%= loup.klass %>? <%= t('AreYouSure') %>" />
            </form>
          ERB

          UNPAUSE_BUTTON = <<~ERB
            <form action="<%= root_path %>loops/<%= loup.lid %>/unpause" method="post">
              <%= csrf_tag %>
              <input class="btn btn-danger btn-unpause" type="submit" name="pause" value="<%= t('Unpause') %>"
                data-confirm="Unpause the job <%= loup.klass %>? <%= t('AreYouSure') %>" />
            </form>
          ERB

          def self.registered(app)
            app.replace_content("/loops") do |content|
              content.gsub!("</header>", "</header>
                <style>
                  .btn-unpause {
                    color: #000;
                    background-image: none;
                    background-color: #ddd;
                  }
                  .btn-unpause:hover {
                    border: 1px solid;
                  }
                </style>")

              # Add the top of the table
              content.gsub!("</th>\n    </tr>", "</th><th><%= t('Pause/Unpause') %></th></th>\n    </tr>")

              # Add the run button
              content.gsub!(
                "</td>\n      </tr>\n    <% end %>",
                "</td>\n<td>" \
                "<% if (loup.paused?) %>#{UNPAUSE_BUTTON}<% else %>#{PAUSE_BUTTON}<% end %>" \
                "</td>\n      </tr>\n    <% end %>"
              )
            end

            app.post("/loops/:lid/pause") do
              Sidekiq::Periodic::Loop.new(params[:lid]).pause!

              return redirect "#{root_path}loops"
            end

            app.post("/loops/:lid/unpause") do
              Sidekiq::Periodic::Loop.new(params[:lid]).unpause!

              return redirect "#{root_path}loops"
            end
          end
        end

        module PauseServer
          def enqueue_job(cycle, ts)
            cycle.paused? ? logger.info("Job #{cycle.klass} is paused by Periodic Pause") : super
          end
        end

        def self.use!
          require("sidekiq-ent/web")
          require("sidekiq-ent/periodic")
          require("sidekiq-ent/periodic/manager")
          require("sidekiq-ent/periodic/static_loop")

          Sidekiq::Web.register(Sidekiq::Belt::Ent::PeriodicPause::SidekiqLoopsPeriodicPause)
          Sidekiq::Periodic::Loop.prepend(Sidekiq::Belt::Ent::PeriodicPause)
          Sidekiq::Periodic::StaticLoop.prepend(Sidekiq::Belt::Ent::PeriodicPause)
          Sidekiq::Periodic::Manager.prepend(Sidekiq::Belt::Ent::PeriodicPause::PauseServer)
        end
      end
    end
  end
end
