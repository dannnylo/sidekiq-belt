# frozen_string_literal: true

require "sidekiq"
require "sidekiq/web"

RSpec.describe(Sidekiq::Belt::Ent::PeriodicRun) do
  describe ".run" do
    let(:options) { { "args" => ["def"] }.to_json }
    let(:dummy_job_class) do
      Class.new do
        include Sidekiq::Worker
      end
    end
    let(:loop_class) do
      Class.new do
        attr_accessor :lid, :klass, :options

        def initialize(lid, klass, options)
          @lid = lid
          @klass = klass
          @options = options
        end
      end
    end

    before do
      loop_class.prepend(described_class)

      allow(dummy_job_class).to receive(:perform_async).and_return(true)
      stub_const("DummyJob", dummy_job_class)
    end

    it "calls perform_async of Job" do
      loop_class.new("abc", "DummyJob", options).run

      expect(dummy_job_class).to have_received(:perform_async).with("def")
    end
  end

  describe ".use!" do
    before do
      stub_const("Sidekiq::Periodic", Module.new)
      stub_const("Sidekiq::Periodic::StaticLoop", Class.new)
      stub_const("Sidekiq::Periodic::Loop", Class.new)

      allow(described_class).to receive(:require).and_return(true)
      allow(Sidekiq::Web.configure).to receive(:register).and_call_original
      allow(Sidekiq::Periodic::Loop).to receive(:prepend)
      allow(Sidekiq::Periodic::StaticLoop).to receive(:prepend)
    end

    it "injects the code" do
      described_class.use!

      expect(described_class).to have_received(:require).with("sidekiq-ent/web").once
      expect(described_class).to have_received(:require).with("sidekiq-ent/periodic").once
      expect(described_class).to have_received(:require).with("sidekiq-ent/periodic/static_loop").once

      expect(Sidekiq::Web.configure).to have_received(:register).with(described_class::SidekiqLoopsPeriodicRun,
                                                                      { index: nil, name: "periodic_run", tab: nil })
      expect(Sidekiq::Periodic::Loop).to have_received(:prepend).with(described_class)
      expect(Sidekiq::Periodic::StaticLoop).to have_received(:prepend).with(described_class)
    end
  end
end
