# frozen_string_literal: true

require "sidekiq"

RSpec.describe(Sidekiq::Belt::Pro::Files) do
  describe ".use!" do
    context "when Sidekiq is not Pro" do
      before do
        allow(Sidekiq).to receive(:pro?).and_return(false)
      end

      it "returns nil" do
        expect(described_class.use!([:all])).to be_nil
      end
    end

    context "when Sidekiq is Pro" do
      before do
        allow(Sidekiq).to receive(:pro?).and_return(true)
      end

      it "returns true" do
        expect(described_class.use!([:all])).to be(true)
      end
    end
  end
end
