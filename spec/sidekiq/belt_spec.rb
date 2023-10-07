# frozen_string_literal: true

RSpec.describe Sidekiq::Belt do
  it "has a version number" do
    expect(Sidekiq::Belt::VERSION).not_to be_nil
  end
end
