# frozen_string_literal: true

RSpec.describe Sidekiq::Belt do
  it "has a version number" do
    expect(Sidekiq::Belt::VERSION).not_to be_nil
  end

  describe ".use!" do
    before do
      allow(Sidekiq::Belt::Community::Files).to receive(:use!).and_return(true)
      allow(Sidekiq::Belt::Pro::Files).to receive(:use!).and_return(true)
      allow(Sidekiq::Belt::Ent::Files).to receive(:use!).and_return(true)
    end

    it "calls use! to Community, Pro and Ent" do
      described_class.use!([:all])

      expect(Sidekiq::Belt::Community::Files).to have_received(:use!).once
      expect(Sidekiq::Belt::Pro::Files).to have_received(:use!).once
      expect(Sidekiq::Belt::Ent::Files).to have_received(:use!).once
    end
  end

  describe ".configure" do
    it "keeps a default configuration" do
      expect(described_class.config.run_jobs).to eq([])

      described_class.configure do |config|
        config.run_jobs.push({ class: "AWorker", args: ["a"], group: "A" })
      end

      expect(described_class.config.run_jobs).to include({ class: "AWorker", args: ["a"], group: "A" })
    end

    it "yields a configuration object" do
      described_class.configure do |config|
        config.run_jobs.push({ class: "AWorker", args: ["a"] })
        config.run_jobs.push({ class: "BWorker" })

        config.run_jobs << { class: "CWorker", args: ["a"], group: "Etc" }
        config.run_jobs << { class: "DWorker", args: ["a"], group: "Etc" }
      end

      expect(described_class.config.run_jobs).to include({ class: "AWorker", args: ["a"] })
      expect(described_class.config.run_jobs).to include({ class: "BWorker" })
      expect(described_class.config.run_jobs).to include({ class: "CWorker", args: ["a"], group: "Etc" })
      expect(described_class.config.run_jobs).to include({ class: "DWorker", args: ["a"], group: "Etc" })
    end
  end
end
