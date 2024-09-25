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

    def erb(content, options = {})
      if content.is_a? Symbol
        unless respond_to?(:"_erb_#{content}")
          views = options[:views] || Web.settings.views
          src = ERB.new(File.read("#{views}/#{content}.erb")).src
          WebAction.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def _erb_#{content}
              #{src}
            end
          RUBY
        end
      end

      if @_erb
        _erb(content, options[:locals])
      else
        @_erb = true
        content = _erb(content, options[:locals])

        _render { content }
      end
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
