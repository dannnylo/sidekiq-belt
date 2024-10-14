# frozen_string_literal: false

require "sidekiq"
require "sidekiq/web"

RSpec.describe(Sidekiq::Belt::Ent::PeriodicPause) do
  let(:redis_mock) { double("redis") }
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
    allow(Sidekiq).to receive(:redis).and_yield(redis_mock)
    allow(dummy_job_class).to receive(:perform_async).and_return(true)
    stub_const("DummyJob", dummy_job_class)
  end

  describe ".paused?" do
    context "when job is paused" do
      before do
        allow(redis_mock).to receive(:hget).and_return("p")
      end

      it "return true to the job" do
        expect(loop_class.new("abc", "DummyJob", {}).paused?).to be(true)
      end
    end

    context "when job is not paused" do
      before do
        allow(redis_mock).to receive(:hget).and_return(nil)
      end

      it "return true to the job" do
        expect(loop_class.new("abc", "DummyJob", {}).paused?).to be(false)
      end
    end
  end

  describe ".pause!" do
    before do
      allow(redis_mock).to receive(:hset).and_return(true)
    end

    it "saves the job as paused" do
      loop_class.new("abc", "DummyJob", {}).pause!

      expect(redis_mock).to have_received(:hset).with("PeriodicPaused", "abc", "p")
    end
  end

  describe ".unpause!" do
    before do
      allow(redis_mock).to receive(:hdel).and_return(true)
    end

    it "removes the job as unpaused" do
      loop_class.new("abc", "DummyJob", {}).unpause!

      expect(redis_mock).to have_received(:hdel).with("PeriodicPaused", "abc")
    end
  end

  describe ".use!" do
    before do
      stub_const("Sidekiq::Periodic", Module.new)
      stub_const("Sidekiq::Periodic::StaticLoop", Class.new)
      stub_const("Sidekiq::Periodic::Loop", Class.new)
      stub_const("Sidekiq::Periodic::Manager", Class.new)

      allow(described_class).to receive(:require).and_return(true)
      allow(Sidekiq::Web).to receive(:register)
      allow(Sidekiq::Periodic::Loop).to receive(:prepend)
      allow(Sidekiq::Periodic::StaticLoop).to receive(:prepend)
      allow(Sidekiq::Periodic::Manager).to receive(:prepend)
    end

    it "injects the code" do
      described_class.use!

      expect(described_class).to have_received(:require).with("sidekiq-ent/web").once
      expect(described_class).to have_received(:require).with("sidekiq-ent/periodic").once
      expect(described_class).to have_received(:require).with("sidekiq-ent/periodic/manager").once
      expect(described_class).to have_received(:require).with("sidekiq-ent/periodic/static_loop").once

      expect(Sidekiq::Web).to have_received(:register).with(described_class::SidekiqLoopsPeriodicPause)
      expect(Sidekiq::Periodic::Loop).to have_received(:prepend).with(described_class)
      expect(Sidekiq::Periodic::StaticLoop).to have_received(:prepend).with(described_class)
      expect(Sidekiq::Periodic::Manager).to have_received(:prepend).with(described_class::PauseServer)
    end
  end

  describe "PauseServer.enqueue_job" do
    let(:logger) { Logger.new($stdout) }
    let(:instance) { dummy_pause_server.new }
    let(:cycle) { loop_class.new("abc", "DummyJob", {}) }
    let(:dummy_pause_server) do
      Class.new do
        def enqueue_job(cycle, ts)
          [cycle, ts]
        end
      end
    end

    before do
      allow(logger).to receive(:info).and_return(true)
      allow(instance).to receive(:logger).and_return(logger)
      dummy_pause_server.prepend(described_class::PauseServer)
    end

    context "when job is paused" do
      before do
        allow(redis_mock).to receive(:hget).and_return("p")
      end

      it "does not run the job" do
        expect(cycle.paused?).to be(true)
        expect(instance.enqueue_job(cycle, 2)).to be(true)

        expect(logger).to have_received(:info).with("Job DummyJob is paused by Periodic Pause")
      end
    end

    context "when job is not paused" do
      it "runs the job" do
        allow(redis_mock).to receive(:hget).and_return(nil)

        expect(instance.enqueue_job(cycle, 2)).to eq([cycle, 2])
      end
    end
  end
end
