# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Community
      module TopLabel
        def self.use!
          Sidekiq::WebActionHelper.change_layout do |content|
            top_label = (Sidekiq::Belt.config.top_label || {}).fetch(Sidekiq::Belt.env, {})

            unless top_label.empty?
              styles = <<~CSS
                .top_label {
                  background: #{::Rack::Utils.escape_html(top_label.fetch(:background_color, "red"))} !important;
                  z-index: 99999;
                  text-align: center;
                  color: #{::Rack::Utils.escape_html(top_label.fetch(:color, "white"))};
                }
              CSS

              nonce = content[/nonce="([^"]*)"/, 1].to_s
              content.gsub!('</head>', "<style nonce='#{nonce}'>#{styles}</style></head>")

              html = "<div class='container-fluid top_label'>&nbsp;#{::Rack::Utils.escape_html(top_label[:text].to_s)}&nbsp;</div>"
              content.gsub!('<div class="container-fluid">', "#{html}<div class='container-fluid'>")
            end
          end
        end
      end
    end
  end
end
