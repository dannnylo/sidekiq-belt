# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Community
      class TopLabel
        def self.use!
          Sidekiq::WebActionHelper.change_layout do |content|
            Sidekiq::Belt::Community::TopLabel.new(content).apply
          end
        end

        attr_reader :content, :top_label

        def initialize(content)
          @content = content
          @top_label = fetch_top_label
        end

        def apply
          inject_styles_and_label unless top_label.empty?

          content
        end

        def fetch_top_label
          (Sidekiq::Belt.config.top_label || {}).fetch(Sidekiq::Belt.env, {})
        end

        def inject_styles_and_label
          content.gsub!("</head>", "<style nonce='#{nonce_id}'>#{styles}</style></head>")
          content.sub!(/<body[^>]*>/, "\\0#{top_label_div}")
        end

        def nonce_id
          content[/nonce="([^"]*)"/, 1].to_s
        end

        def top_label_div
          text = ::Rack::Utils.escape_html(top_label[:text].to_s)
          "<div class='container-fluid top_label'>&nbsp;#{text}&nbsp;</div>"
        end

        def styles
          <<~CSS
            header:first-of-type, .navbar-default {
              margin-top: 20px;
            }

            .top_label {
              background: #{::Rack::Utils.escape_html(top_label.fetch(:background_color, "red"))} !important;
              z-index: 99999;
              text-align: center;
              color: #{::Rack::Utils.escape_html(top_label.fetch(:color, "white"))};
              position: fixed;
              width: 100%;
              top: 0;
              right: 0;
            }
          CSS
        end
      end
    end
  end
end
