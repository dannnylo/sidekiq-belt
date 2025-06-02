# frozen_string_literal: true

require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Ent
      module PeriodicPause
        module SidekiqLoopsPeriodicPause
          PAUSE_BUTTON = <<~ERB
            name="pause" data-confirm="Pause the job <%= loup.klass %>? <%= t('AreYouSure') %>"
          ERB

          UNPAUSE_BUTTON = <<~ERB
            name="unpause" data-confirm="Unpause the job <%= loup.klass %>? <%= t('AreYouSure') %>"
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

              content.gsub!("name=\"pause\"", PAUSE_BUTTON)
              content.gsub!("name=\"unpause\"", UNPAUSE_BUTTON)
            end
          end
        end

        def self.use!
          require("sidekiq-ent/web")

          Sidekiq::Web.configure do |cfg|
            cfg.register(Sidekiq::Belt::Ent::PeriodicPause::SidekiqLoopsPeriodicPause, name: "periodic_pause",
                                                                                       tab: nil, index: nil)
          end
        end
      end
    end
  end
end
