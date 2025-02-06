# frozen_string_literal: true

require "sidekiq/web/helpers"
require "sidekiq/web/router"
require_relative "web_action_helper"

module Sidekiq
  module WebRouterHelper
    def replace_content(path, &block)
      Sidekiq::Config::DEFAULTS[:replace_views] ||= {}
      Sidekiq::Config::DEFAULTS[:replace_views][path.to_s] ||= []
      Sidekiq::Config::DEFAULTS[:replace_views][path.to_s] << block
    end
  end

  if defined?(Sidekiq::Web::Router)
    Sidekiq::Web::Router.prepend(Sidekiq::WebRouterHelper)
  else
    Sidekiq::WebRouter.prepend(Sidekiq::WebRouterHelper)
  end
end
