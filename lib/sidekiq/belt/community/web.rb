# frozen_string_literal: true

require "sidekiq/web/helpers"
require "sidekiq/web/action"

module Sidekiq
  module ReplaceContents
    def self.blocks
      @blocks ||= {}
    end
  end

  module WebRouter
    def remove(method, path)
      @routes[method.to_s.upcase].delete_if { |x| x.pattern == path.to_s }
    end

    def replace_content(path, &block)
      Sidekiq::ReplaceContents.blocks[path.to_s] ||= []
      Sidekiq::ReplaceContents.blocks[path.to_s] << block
    end
  end

  module WebActionHelper
    def render(engine, content, options = {})
      begin
        path_info = /"([^"]*)"/.match(block.source.to_s)[1]
      rescue StandardError
        path_info = nil
      end

      path_info ||= ::Rack::Utils.unescape(env["PATH_INFO"])

      Sidekiq::ReplaceContents.blocks.fetch(path_info.to_s, []).each do |content_block|
        content_block.call(content)
      end

      super(engine, content, options)
    end
  end

  Sidekiq::WebAction.prepend(Sidekiq::WebActionHelper)
end
