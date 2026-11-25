require "rails_helper"

RSpec.describe Manage::Ratings do
  subject(:manager) { described_class.new(user) }

  let(:user) { FactoryBot.create(:user) }
  let(:item) { FactoryBot.create(:episode) }
  let(:error_class) { described_class::InvalidRating }

  describe "#initialize" do
    it "uses the supplied user as the owner" do
      expect(manager.set!(item, score: 8).user).to eq(user)
    end
  end

  describe "#set!" do
    it "creates a rating from form input without changing tracking" do
      item
      user

      expect {
        manager.set!(item, score: "8")
      }.to change(Rating, :count).by(1)
        .and change(HistoryItem, :count).by(0)
        .and change(CollectionItem, :count).by(0)
        .and change(StackItem, :count).by(0)
      expect(user.ratings.find_by!(item:).score).to eq(8)
    end

    it "replaces the existing score and leaves a repeated submission alone" do
      rating = manager.set!(item, score: 1)
      replacement = manager.set!(item, score: 10)
      expect(replacement).to eq(rating)
      expect(rating.reload.score).to eq(10)
      expect { manager.set!(item, score: 10) }.not_to change { rating.reload.updated_at }
    end

    it "rejects malformed, missing, fractional and out-of-range scores" do
      [nil, 7.5, "8abc", true, [8], 0, 11].each do |score|
        expect { manager.set!(item, score:) }.to raise_error(error_class, /whole number/)
      end
      expect(user.ratings).to be_empty
    end

    it "requires a persisted user" do
      [nil, User.new].each do |owner|
        expect { described_class.new(owner).set!(item, score: 8) }.to raise_error(error_class, /persisted user/)
      end
    end

    it "requires a persisted supported item" do
      [nil, Episode.new, user].each do |target|
        expect { manager.set!(target, score: 8) }.to raise_error(error_class, /persisted movie/)
      end
    end

    it "rejects new ratings for unknown or future releases" do
      [nil, Date.current.tomorrow].each do |air_date|
        item.update!(original_air_date: air_date)
        expect { manager.set!(item, score: 6) }.to raise_error(error_class, /unreleased/)
      end
      expect(user.ratings).to be_empty
    end

    it "preserves a rating when its item's release date moves into the future" do
      rating = manager.set!(item, score: 6)
      item.update!(original_air_date: Date.current.tomorrow)

      expect(manager.set!(item, score: 6)).to eq(rating)
      expect { manager.set!(item, score: 9) }.to raise_error(error_class, /unreleased/)
      expect(rating.reload.score).to eq(6)
    end

    it "accepts a released Specials season" do
      specials = item.show.seasons.find_by!(number: 0)
      FactoryBot.create(:episode, season: specials)

      expect(manager.set!(specials.reload, score: 8).item).to eq(specials)
    end
  end

  describe "#remove!" do
    it "removes the owner's rating even if the release date moves into the future" do
      manager.set!(item, score: 8)
      other_rating = Rating.create!(user: FactoryBot.create(:user), item:, score: 3)
      item.update!(original_air_date: Date.current.tomorrow)

      expect { manager.remove!(item) }.to change { user.ratings.count }.from(1).to(0)
      expect(other_rating.reload.score).to eq(3)
      expect { manager.remove!(item) }.not_to change(Rating, :count)
    end

    it "requires a persisted user and supported item" do
      expect { described_class.new(nil).remove!(item) }.to raise_error(error_class, /persisted user/)
      expect { manager.remove!(user) }.to raise_error(error_class, /persisted movie/)
    end
  end

  describe "#scores_for" do
    it "returns only the owner's scores for a mixed list in one query" do
      movie = FactoryBot.create(:movie, :with_release_date)
      unrated = FactoryBot.create(:episode)
      FactoryBot.create(:rating, user:, item:, score: 7)
      FactoryBot.create(:rating, user:, item: movie, score: 9)
      FactoryBot.create(:rating, item: unrated, score: 10)

      queries = []
      track_ratings_query = ->(_name, _start, _finish, _id, payload) {
        queries << payload[:sql] if payload[:sql].include?('FROM "ratings"')
      }
      scores = ActiveSupport::Notifications.subscribed(track_ratings_query, "sql.active_record") do
        manager.scores_for([item, movie, unrated])
      end

      expect(scores).to eq(item => 7, movie => 9, unrated => nil)
      expect(queries.size).to eq(1)
    end

    it "returns no scores for a guest or an empty list" do
      expect(described_class.new(nil).scores_for([item])).to eq({})
      expect(manager.scores_for([])).to eq({})
    end
  end
end
