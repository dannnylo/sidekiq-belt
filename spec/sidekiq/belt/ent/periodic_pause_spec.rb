# frozen_string_literal: false

require "sidekiq"
require "sidekiq/web"

RSpec.describe(Sidekiq::Belt::Ent::PeriodicPause) do
  describe ".use!" do
    before do
      stub_const("Sidekiq::Periodic", Module.new)

      allow(described_class).to receive(:require).and_return(true)
      allow(Sidekiq::Web.configure).to receive(:register).and_call_original
    end

    it "injects the code" do
      described_class.use!

      expect(described_class).to have_received(:require).with("sidekiq-ent/web").once

      expect(Sidekiq::Web.configure).to have_received(:register).with(described_class::SidekiqLoopsPeriodicPause,
                                                                      { index: nil, name: "periodic_pause", tab: nil })
    end
  end
end
