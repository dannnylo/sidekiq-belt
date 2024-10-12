# frozen_string_literal: true

require "sidekiq/web/helpers"
require "sidekiq/web/action"

module Sidekiq
  module WebActionHelper
    class ERB < ::ERB
      def initialize(content)
        replace_views = Sidekiq::Config::DEFAULTS[:replace_views] || {}

        replace_views.each do |key, content_blocks|
          next if WebRoute.new("", key, true).match("", self.class.path_info).nil?

          content_blocks.each do |content_block|
            content_block.call(content)
          end
        end

        super
      end

      class << self
        attr_accessor :path_info
      end
    end

    def erb(content, options = {})
      ERB.path_info = ::Rack::Utils.unescape(env["PATH_INFO"])

      super
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
