# frozen_string_literal: true

require "sidekiq/web/helpers"
require "sidekiq/web/action"

module Sidekiq
  module WebActionHelper
    def self.blocks
      @blocks ||= {}
    end

    def render(engine, content, options = {})
      begin
        path_info = /"([^"]*)"/.match(block.source.to_s)[1]
      rescue StandardError
        path_info = nil
      end

      path_info ||= ::Rack::Utils.unescape(env["PATH_INFO"])

      Sidekiq::WebActionHelper.blocks.fetch(path_info.to_s, []).each do |content_block|
        content_block.call(content)
      end

      super(engine, content, options)
    end
  end

  Sidekiq::WebAction.prepend(Sidekiq::WebActionHelper)
end
