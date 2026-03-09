require "rails_helper"

RSpec.describe RuntimeFormatter do
  let(:object) { Movie.new }
  subject { RuntimeFormatter.new(object).format }

  before do
    allow(object).to receive(:runtime).and_return(runtime)
  end

  context "when there is no runtime" do
    let(:runtime) { 0 }

    it { should eq "0m" }
  end

  context "when runtime is less than a day but greater than an hour" do
    let(:runtime) { 1439 }

    it { should eq "23h 59m" }
  end

  context "when runtime is greater than a day with no remaining hours" do
    let(:runtime) { 1440 }

    it { should eq "1d 0m" }
  end

  context "when runtime is greater than a day with remaining hours" do
    let(:runtime) { 1530 }

    it { should eq "1d 1h 30m" }
  end

  context "when runtime is greather than an hour with no remaining minutes" do
    let(:runtime) { 60 }

    it { should eq "1h 0m" }
  end

  context "when runtime is less than an hour" do
    let(:runtime) { 30 }

    it { should eq "30m" }
  end
end
