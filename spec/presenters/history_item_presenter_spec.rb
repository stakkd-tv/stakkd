require "rails_helper"

RSpec.describe HistoryItemPresenter, type: :presenter do
  let(:presenter) { described_class.new(history_item) }
  let(:history_item) { FactoryBot.create(:history_item, item:, consumed_at:) }
  let(:consumed_at) { nil }

  describe "#title" do
    subject { presenter.title }

    context "when item is an episode" do
      let(:show) { FactoryBot.create(:show, translated_title: "Test Show") }
      let(:season) { FactoryBot.create(:season, number: 1, show:) }
      let(:item) { FactoryBot.create(:episode, season:, number: 1) }

      it { should eq "Test Show" }
    end

    context "when item is a movie" do
      let(:item) { FactoryBot.create(:movie, translated_title: "Test Movie") }

      it { should eq "Test Movie" }
    end

    context "when item is neither" do
      let(:show) { FactoryBot.create(:show, translated_title: "Test Show") }
      let(:item) { FactoryBot.create(:season, number: 1, show:) }

      it { should eq "Test Show - Season 1" }
    end
  end

  describe "#subtitle" do
    subject { presenter.subtitle }

    context "when item is an episode" do
      let(:show) { FactoryBot.create(:show, translated_title: "Test Show") }
      let(:season) { FactoryBot.create(:season, number: 1, show:) }
      let(:item) { FactoryBot.create(:episode, season:, number: 1, translated_name: "Test Episode") }

      it { should eq "S1E1 - Test Episode" }
    end

    context "when item is not an episode" do
      let(:item) { FactoryBot.create(:movie, translated_title: "Test Movie") }

      it { should eq "Movie" }
    end
  end

  describe "#formatted_consumed_at" do
    subject { presenter.formatted_consumed_at }

    let(:item) { FactoryBot.create(:episode) }

    context "when consumed at is present" do
      let(:consumed_at) { DateTime.new(2026, 1, 1, 10) }

      it { should eq "January 1, 2026 10:00 AM" }
    end

    context "when consumed at is not present" do
      let(:consumed_at) { nil }

      it { should eq "Unknown date" }
    end
  end
end
