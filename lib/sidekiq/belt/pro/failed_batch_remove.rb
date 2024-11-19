# frozen_string_literal: true

require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Pro
      module FailedBatchRemove
        module SidekiqFailedBatchRemove
          REMOVE_BUTTON = <<~ERB
            <form action="<%= root_path %>batches/<%= bid %>/remove" method="post">
              <%= csrf_tag %>
              <input class="btn btn-danger" type="submit" name="remove" value="<%= t('Remove') %>"
                data-confirm="Do you want to remove batch <%= bid %>? <%= t('AreYouSure') %>" />
            </form>
          ERB

          def self.registered(app)
            app.replace_content("/batches") do |content|
              content.gsub!("</th>\n      <%", "</th><th><%= t('Delete') %></th>\n      <%")

              content.gsub!(
                "</td>\n        </tr>\n      <% end %>",
                "</td>\n<td>#{REMOVE_BUTTON}</td>\n        </tr>\n      <% end %>"
              )
            end

            app.post("/batches/:bid/remove") do
              Sidekiq::Batch::Status.new(params[:bid]).delete

              return redirect "#{root_path}batches"
            end
          end
        end

        def self.use!
          require("sidekiq/web")

          Sidekiq::Web.register(Sidekiq::Belt::Pro::FailedBatchRemove::SidekiqFailedBatchRemove)
        end
      end
    end
  end
end
