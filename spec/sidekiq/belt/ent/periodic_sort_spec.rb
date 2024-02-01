# frozen_string_literal: true

require "sidekiq"
require "sidekiq/web"

RSpec.describe(Sidekiq::Belt::Ent::PeriodicSort) do
  describe ".each" do
    let(:dummy_class) do
      Class.new do
        def initialize(lids)
          @lids = lids
        end
      end
    end

    let(:jobs) do
      [
        Sidekiq::Periodic::Loop.new(1, "BClass"),
        Sidekiq::Periodic::Loop.new(2, "DClass"),
        Sidekiq::Periodic::Loop.new(3, "CClass"),
        Sidekiq::Periodic::Loop.new(4, "AClass"),
        Sidekiq::Periodic::Loop.new(5, "ZClass")
      ]
    end

    before do
      dummy_class.prepend(described_class::SidekiqLoopsPeriodicSort)
      stub_const("Sidekiq::Periodic", Module.new)
      stub_const("Sidekiq::Periodic::Loop", Struct.new(:id, :klass))

      allow(Sidekiq::Periodic::Loop).to receive(:new).and_return(jobs[0], jobs[1], jobs[2], jobs[3], jobs[4])
    end

    it "sort periodic jobs by class name" do
      expect(dummy_class.new(
        [1, 2, 3, 4, 5]
      ).each.map(&:klass)).to eq(%w[AClass BClass CClass DClass ZClass])
    end
  end

  describe ".use!" do
    before do
      stub_const("Sidekiq::Periodic", Module.new)
      stub_const("Sidekiq::Periodic::LoopSet", Class.new)

      allow(described_class).to receive(:require).and_return(true)
      allow(Sidekiq::Periodic::LoopSet).to receive(:prepend)
    end

    it "injects the code" do
      described_class.use!

      expect(described_class).to have_received(:require).with("sidekiq-ent/periodic").once
      expect(described_class).to have_received(:require).with("sidekiq-ent/periodic/static_loop").once

      expect(Sidekiq::Periodic::LoopSet).to have_received(:prepend).with(described_class::SidekiqLoopsPeriodicSort)
    end
  end
end
