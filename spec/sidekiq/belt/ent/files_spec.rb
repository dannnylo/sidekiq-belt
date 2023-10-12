# frozen_string_literal: true

require "sidekiq"

RSpec.describe(Sidekiq::Belt::Ent::Files) do
  describe ".use!" do
    before do
      allow(Sidekiq::Belt::Ent::PeriodicPause).to receive(:use!).and_return(true)
      allow(Sidekiq::Belt::Ent::PeriodicRun).to receive(:use!).and_return(true)
    end

    context "when Sidekiq is not Ent" do
      before do
        allow(Sidekiq).to receive(:ent?).and_return(false)
      end

      it "does not calls use! of PeriodicPause and PeriodicRun" do
        described_class.use!([:all])

        expect(Sidekiq::Belt::Ent::PeriodicPause).not_to have_received(:use!)
        expect(Sidekiq::Belt::Ent::PeriodicRun).not_to have_received(:use!)
      end
    end

    context "when Sidekiq is Ent" do
      context "when options is :all" do
        before do
          allow(Sidekiq).to receive(:ent?).and_return(true)
        end

        it "calls use! of PeriodicPause and PeriodicRun" do
          described_class.use!([:all])

          expect(Sidekiq::Belt::Ent::PeriodicPause).to have_received(:use!).once
          expect(Sidekiq::Belt::Ent::PeriodicRun).to have_received(:use!).once
        end
      end

      context "when options is :periodic_run" do
        before do
          allow(Sidekiq).to receive(:ent?).and_return(true)
        end

        it "calls only use! to PeriodicPause and PeriodicRun" do
          described_class.use!([:periodic_run])

          expect(Sidekiq::Belt::Ent::PeriodicPause).not_to have_received(:use!)
          expect(Sidekiq::Belt::Ent::PeriodicRun).to have_received(:use!)
        end
      end

      context "when options is :periodic_pause" do
        before do
          allow(Sidekiq).to receive(:ent?).and_return(true)
        end

        it "calls only use! to PeriodicPause and PeriodicRun" do
          described_class.use!([:periodic_pause])

          expect(Sidekiq::Belt::Ent::PeriodicPause).to have_received(:use!)
          expect(Sidekiq::Belt::Ent::PeriodicRun).not_to have_received(:use!)
        end
      end
    end
  end
end
