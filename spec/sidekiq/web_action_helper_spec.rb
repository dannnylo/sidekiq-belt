# frozen_string_literal: false

RSpec.describe(Sidekiq::WebActionHelper) do
  describe "ERB" do
    let(:dummy_web_action) do
      Class.new do
        def env
          { "PATH_INFO" => "/" }
        end

        def render(_engine, content, _options = {})
          content
        end
      end
    end

    before do
      Sidekiq::Config::DEFAULTS[:replace_views] ||= {}
      Sidekiq::Config::DEFAULTS[:replace_views]["/"] = blocks

      dummy_web_action.prepend(described_class)
    end

    context "when there are a replace block to the path" do
      let(:blocks) do
        [
          proc { |content| content.gsub!("default", "replaced") },
          proc { |content| content.gsub!("replaced", "replaced twice") }
        ]
      end

      it "replaces the page content with the block content" do
        dummy_web_action::ERB.path_info = "/"
        expect(dummy_web_action::ERB.new("<a>Sidekiq default<a>").result).to eq("<a>Sidekiq replaced twice<a>")
      end
    end

    context "when does not exists a replace block to the path" do
      let(:blocks) do
        []
      end

      it "replaces the page content with the block content" do
        dummy_web_action::ERB.path_info = "/"
        expect(dummy_web_action::ERB.new("<a>Sidekiq default<a>").result).to eq("<a>Sidekiq default<a>")
      end
    end
  end
end
