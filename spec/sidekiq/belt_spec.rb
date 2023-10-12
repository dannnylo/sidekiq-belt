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
end
