# frozen_string_literal: true

require "sidekiq/web/helpers"

module Sidekiq
  module Belt
    module Pro
      module ForceBatchCallback
        module SidekiqForceBatchCallback
          def self.action_button(action)
            action_name = "force_#{action}"
            action_chars = action.chars
            action_button = action_chars.capitalize
            <<~ERB
              <form action="<%= root_path %>batches/<%= @batch.bid %>/force_callback/#{action}" method="post">
                <%= csrf_tag %>
                <input class="btn btn-danger" type="submit" name="#{action_name}" value="<%= t('#{action_button}') %>"
                  data-confirm="Do you want to force the #{action} callback for batch <%= @batch.bid %>? <%= t('AreYouSure') %>" />
              </form>
            ERB
          end

          def self.registered(app)
            app.replace_content("/batches/:bid") do |content|
              content.sub!(/(<\/tbody>)/) do |match|
                <<-HTML
                  <tr>
                    <th><%= t("Force Action") %></th>
                    <td>
                      <div style="display: flex;">
                        #{action_button('success')}
                        #{action_button('complete')}
                        #{action_button('death')}
                      </div>
                    </td>
                  </tr>
                  #{match}
                HTML
              end
            end

            app.post("/batches/:bid/force_callback/:action") do
              Sidekiq::Batch::Callback.perform_inline(params[:action], params[:bid])

              return redirect "#{root_path}batches"
            end
          end
        end

        def self.use!
          require("sidekiq/web")

          Sidekiq::Web.register(Sidekiq::Belt::Pro::ForceBatchCallback::SidekiqForceBatchCallback)
        end
      end
    end
  end
end
