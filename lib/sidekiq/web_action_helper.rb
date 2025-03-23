# frozen_string_literal: true

require "sidekiq/web/helpers"
require "sidekiq/web/action"

module Sidekiq
  module WebActionHelper
    class ERB < ::ERB
      def initialize(content)
        replace_views = Sidekiq::Config::DEFAULTS[:replace_views] || {}

        replace_views.each do |key, content_blocks|
          router = Sidekiq::Web::Route.new(self.class.sidekiq_request_method, key, true)

          next if router.match(self.class.sidekiq_request_method, self.class.sidekiq_path_info).nil?

          content_blocks.each do |content_block|
            content_block.call(content)
          end
        end

        super
      end

      class << self
        attr_accessor :sidekiq_request_method, :sidekiq_path_info
      end
    end

    def erb(content, options = {})
      ERB.sidekiq_request_method = env["REQUEST_METHOD"].to_s.downcase
      ERB.sidekiq_path_info = env["PATH_INFO"].to_s

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

  Sidekiq::Web::Action.prepend(Sidekiq::WebActionHelper)
end
