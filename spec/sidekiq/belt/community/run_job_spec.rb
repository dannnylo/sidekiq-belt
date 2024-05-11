# frozen_string_literal: true

require "sidekiq"
require "sidekiq/web"

RSpec.describe(Sidekiq::Belt::Community::RunJob) do
  describe ".use!" do
    it "injects the code" do
      allow(Sidekiq::Web).to receive(:register)

      described_class.use!

      expect(Sidekiq::Web).to have_received(:register).with(described_class::SidekiqRunJob)
    end

    it "registers the tab 'Run Jobs' with the path 'run_jobs'" do
      described_class.use!

      expect(Sidekiq::Web.tabs).to eq({ "Run Jobs" => "run_jobs" })

      routes = Sidekiq::WebApplication.instance_variable_get(:@routes)

      route = routes["GET"].select { |r| r.pattern == "/run_jobs" }.first
      expect(route).to be_a(Sidekiq::WebRoute)

      route = routes["POST"].select { |r| r.pattern == "/run_jobs/:rjid/run" }.first
      expect(route).to be_a(Sidekiq::WebRoute)
    end
  end

  describe ".list_grouped_jobs" do
    let(:expected_jobs) do
      {
        "" => [
          { class: "AWorker", args: ["a"],
            id: 0 }, { class: "BWorker", id: 2 }
        ],
        "Etc" => [{ class: "CWorker", args: ["a"], group: "Etc", id: 1 },
                  { class: "DWorker", args: ["a"],
                    group: "Etc", id: 3 }]
      }
    end

    before do
      Sidekiq::Belt.configure do |config|
        config.run_jobs.push({ class: "AWorker", args: ["a"] })

        config.run_jobs << { class: "CWorker", args: ["a"], group: "Etc" }
        config.run_jobs.push({ class: "BWorker" })
        config.run_jobs << { class: "DWorker", args: ["a"], group: "Etc" }
      end
    end

    after do
      Sidekiq::Belt.configure do |config|
        config.run_jobs = []
      end
    end

    it "lists grouped jobs" do
      expect(described_class.list_grouped_jobs).to eq(expected_jobs)
    end
  end

  describe ".run_job" do
    let(:dummy_job_class) do
      Class.new do
        include Sidekiq::Worker
      end
    end

    before do
      stub_const("DWorker", dummy_job_class)

      Sidekiq::Belt.configure do |config|
        config.run_jobs.push({ class: "AWorker", args: ["a"] })
        config.run_jobs.push({ class: "BWorker" })

        config.run_jobs << { class: "CWorker", args: ["a"], group: "Etc" }
        config.run_jobs << { class: "DWorker", args: ["a"], group: "Etc" }
      end

      allow(DWorker).to receive(:perform_async)
    end

    after do
      Sidekiq::Belt.configure do |config|
        config.run_jobs = []
      end
    end

    it "runs the selected job" do
      described_class.run_job(3)
      expect(DWorker).to have_received(:perform_async).with("a")
    end
  end
end
