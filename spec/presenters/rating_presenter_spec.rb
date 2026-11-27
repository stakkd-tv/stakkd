require "rails_helper"

RSpec.describe RatingPresenter, type: :presenter do
  let(:item) { FactoryBot.build_stubbed(:movie, translated_title: "Test Movie") }
  let(:rating) { FactoryBot.build_stubbed(:rating, item:) }
  let(:presenter) { described_class.new(rating) }

  describe "#initialize" do
    it "wraps the supplied rating" do
      expect(described_class.new(rating).rating).to equal(rating)
    end
  end

  describe "#rating" do
    it "returns the original rating" do
      expect(presenter.rating).to equal(rating)
    end
  end

  describe "#item" do
    it "returns the item belonging to the rating" do
      expect(presenter.item).to equal(item)
    end
  end

  describe "#title" do
    subject { presenter.title }

    context "when the item is a movie" do
      it { should eq "Test Movie" }
    end

    context "when the item is a show" do
      let(:item) { FactoryBot.build_stubbed(:show, translated_title: "Test Show") }

      it { should eq "Test Show" }
    end

    context "when the item is a season" do
      let(:show) { FactoryBot.build_stubbed(:show, translated_title: "Test Show") }
      let(:item) { FactoryBot.build_stubbed(:season, show:, translated_name: "The Beginning") }

      it { should eq "Test Show" }
    end

    context "when the item is an episode" do
      let(:show) { FactoryBot.build_stubbed(:show, translated_title: "Test Show") }
      let(:season) { FactoryBot.build_stubbed(:season, show:) }
      let(:item) { FactoryBot.build_stubbed(:episode, season:, translated_name: "The Crossing") }

      it { should eq "Test Show" }
    end
  end

  describe "#subtitle" do
    subject { presenter.subtitle }

    context "when the item is a movie" do
      it { should eq "Movie" }
    end

    context "when the item is a show" do
      let(:item) { FactoryBot.build_stubbed(:show) }

      it { should eq "Show" }
    end

    context "when the item is a season with its default name" do
      let(:item) { FactoryBot.build_stubbed(:season, number: 2, translated_name: "Season 2") }

      it "does not repeat the season number" do
        should eq "Season 2"
      end
    end

    context "when the item is a season with a custom name" do
      let(:item) { FactoryBot.build_stubbed(:season, number: 2, translated_name: "The Return") }

      it { should eq "Season 2 · The Return" }
    end

    context "when the item is Specials" do
      let(:item) { FactoryBot.build_stubbed(:season, number: 0, translated_name: "Specials") }

      it { should eq "Specials" }
    end

    context "when Specials has a custom name" do
      let(:item) { FactoryBot.build_stubbed(:season, number: 0, translated_name: "Bonus episodes") }

      it { should eq "Bonus episodes" }
    end

    context "when the item is an episode" do
      let(:season) { FactoryBot.build_stubbed(:season, number: 2) }
      let(:item) { FactoryBot.build_stubbed(:episode, season:, number: 4, translated_name: "The Crossing") }

      it { should eq "S2E4 · The Crossing" }
    end

    context "when the item is a Specials episode" do
      let(:season) { FactoryBot.build_stubbed(:season, number: 0) }
      let(:item) { FactoryBot.build_stubbed(:episode, season:, number: 1, translated_name: "Holiday special") }

      it { should eq "S0E1 · Holiday special" }
    end
  end

  describe "#poster" do
    %i[movie show season].each do |type|
      context "when the item is a #{type}" do
        let(:item) { FactoryBot.create(type) }

        it "returns the item's small poster variant" do
          item.posters.attach(io: File.open(Rails.root.join("spec/support/assets/300x450.png")), filename: "poster.png", content_type: "image/png")
          expected = item.posters.first.variant(:small)
          expect(presenter.poster.blob).to eq(expected.blob)
          expect(presenter.poster.variation.key).to eq(expected.variation.key)
        end

        it "returns the poster fallback when no poster exists" do
          expect(presenter.poster).to eq("2:3.png")
        end
      end
    end

    context "when the item is an episode" do
      let(:item) { FactoryBot.create(:episode) }

      it "uses the season's small poster rather than a landscape episode image" do
        item.season.posters.attach(io: File.open(Rails.root.join("spec/support/assets/300x450.png")), filename: "poster.png", content_type: "image/png")
        expected = item.season.posters.first.variant(:small)
        expect(presenter.poster.blob).to eq(expected.blob)
        expect(presenter.poster.variation.key).to eq(expected.variation.key)
      end

      it "returns the poster fallback when the season has no poster" do
        expect(presenter.poster).to eq("2:3.png")
      end
    end
  end
end
