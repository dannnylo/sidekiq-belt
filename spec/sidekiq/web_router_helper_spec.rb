# frozen_string_literal: true

RSpec.describe(Sidekiq::WebRouterHelper) do
  describe ".render" do
    let(:dummy_web_router) do
      Class.new
    end

    let(:instance_web_router) do
      dummy_web_router.new
    end

    it "replaces the page content with the block content" do
      dummy_web_router.prepend(described_class)

      instance_web_router.replace_content("/") do |content|
        content.gsub!("default", "replaced")
      end

      instance_web_router.replace_content("/") do |content|
        content.gsub!("replaced", "replaced twice")
      end

      expect(Sidekiq::Config::DEFAULTS[:replace_views]["/"].size).to eq(2)
    end
  end
end
