require "spec_helper"
require_relative "../../../lib/tracking/completion"

RSpec.describe Tracking::Completion do
  let(:movie) { double("movie", id: 1, class: double(polymorphic_name: "Movie")) }
  let(:episode) { double("episode", id: 1, class: double(polymorphic_name: "Episode")) }

  it "treats an empty selection as none" do
    expect(described_class.new([], [["Movie", 1]]).status).to eq(:none)
  end

  it "distinguishes types with the same id" do
    expect(described_class.new([movie, episode], [["Movie", 1]]).status).to eq(:partial)
  end

  it "ignores duplicate selections and repeated records" do
    expect(described_class.new([movie, movie], [["Movie", 1], ["Movie", 1]]).status).to eq(:completed)
  end

  it "returns none when only unrelated records exist" do
    expect(described_class.new([episode], [["Movie", 1]]).status).to eq(:none)
  end
end
