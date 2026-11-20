require "rails_helper"

RSpec.describe Collections::Dialog do
  let(:user) { FactoryBot.create(:user) }
  let(:show) { FactoryBot.create(:show, :with_premiere_date) }
  let(:season) { show.seasons_without_specials.first }
  let(:episode) { season.episodes.first }

  describe "#initialize" do
    it "binds the summary to the given owner and title" do
      other = FactoryBot.create(:user)
      Manage::Collection.new(user).add!(episode)
      expect(described_class.new(user, episode).as_json).to include(title: episode.to_s, owned: 1)
      expect(described_class.new(other, episode).as_json).to include(title: episode.to_s, owned: 0)
    end
  end

  describe "#as_json" do
    it "reports partial format coverage without exposing other users' formats" do
      second = FactoryBot.create(:episode, season:, number: 2)
      FactoryBot.create(:episode, season:, number: 3, original_air_date: Date.tomorrow)
      common = FactoryBot.create(:collection_format, :common)
      Manage::Collection.new(user).add!(episode, formats: [common])
      Manage::Collection.new(user).add!(second)
      FactoryBot.create(:collection_format)
      result = described_class.new(user, show).as_json
      expect(result).to include(container: true, excludes_specials: true, owned: 2, total: 2)
      expect(result[:formats]).to eq([{id: common.id, name: common.name, count: 1}])
      expect(result[:affected_items]).to include("Show:#{show.id}" => :completed, "Season:#{season.id}" => :completed, "Episode:#{episode.id}" => :completed)
    end

    it "includes ancestors for an episode" do
      expect(described_class.new(user, episode).as_json[:affected_items]).to include("Show:#{show.id}" => :none, "Season:#{season.id}" => :none)
    end

    it "prevents adding unreleased movies and empty containers" do
      movie = FactoryBot.create(:movie)
      expect(described_class.new(user, movie).as_json).to include(container: false, can_add: false)
      expect(described_class.new(user, FactoryBot.create(:show)).as_json).to include(total: 0, can_add: false)
    end

    it "does not count specials in the show scope" do
      special = FactoryBot.create(:episode, season: show.seasons.find_by!(number: 0))
      Manage::Collection.new(user).add!(special, formats: ["VHS"])
      expect(described_class.new(user, show).as_json).to include(owned: 0, total: 1)
      expect(described_class.new(user, special).as_json).to include(owned: 1, total: 1, excludes_specials: false)
    end
  end
end
