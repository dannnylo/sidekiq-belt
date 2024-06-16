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

            html = "<div class='container-fluid'
                         style='background: #{::Rack::Utils.escape_html(top_label.fetch(:background_color, 'red'))};
                                text-align: center;
                                color: #{::Rack::Utils.escape_html(top_label.fetch(:color, 'white'))};'>
                      &nbsp;#{::Rack::Utils.escape_html(top_label[:text].to_s)}&nbsp;
                    </div>"
            content.gsub!('<div class="container-fluid">', "#{html} <div class='container-fluid'>") unless top_label.empty?
          end
        end
      end
    end
  end
end
