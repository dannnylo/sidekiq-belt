# frozen_string_literal: true

require "sidekiq/web/helpers"
require "sidekiq/web/action"

module Sidekiq
  module WebActionHelper
    def render(engine, content, options = {})
      begin
        path_info = /"([^"]*)"/.match(block.source.to_s)[1]
      rescue StandardError
        path_info = nil
      end

      path_info ||= ::Rack::Utils.unescape(env["PATH_INFO"])

      replace_views = Sidekiq::Config::DEFAULTS[:replace_views] || {}

      replace_views.fetch(path_info.to_s, []).each do |content_block|
        content_block.call(content)
      end

      super(engine, content, options)
    end

    def self.change_layout(&block)
      Sidekiq::Config::DEFAULTS[:layout_changes] ||= []
      Sidekiq::Config::DEFAULTS[:layout_changes] << block
    end

    def _render
      content = super

      layout_changes = Sidekiq::Config::DEFAULTS[:layout_changes] || []

      layout_changes.each do |content_block|
        content_block.call(content)
      end

      content
    end
  end

  Sidekiq::WebAction.prepend(Sidekiq::WebActionHelper)
end
