require "rails_helper"

RSpec.describe Manage::Collection do
  before do
    CollectionFormat::COMMON_NAMES.each { |name| FactoryBot.create(:collection_format, :common, name:) }
  end

  let(:user) { FactoryBot.create(:user) }
  let(:manager) { described_class.new(user) }
  let(:movie) { FactoryBot.create(:movie, :with_release_date) }

  shared_context "with released and unreleased episodes" do
    let(:show) { FactoryBot.create(:show, :with_premiere_date) }
    let(:season) { show.seasons_without_specials.first }
    let(:first) { season.episodes.first }
    let!(:second) { FactoryBot.create(:episode, season:, number: 2, original_air_date: Date.yesterday) }
    let!(:future) { FactoryBot.create(:episode, season:, number: 3, original_air_date: Date.tomorrow) }
    let!(:undated) { FactoryBot.create(:episode, season:, number: 4, original_air_date: nil) }
    let(:specials) { show.seasons.find_by!(number: 0) }
    let!(:special) { FactoryBot.create(:episode, season: specials, original_air_date: Date.yesterday) }
  end

  describe "#initialize" do
    it "accepts the collection owner" do
      expect(described_class.new(user).user).to eq(user)
    end
  end

  describe "#user" do
    it "returns the collection owner" do
      expect(manager.user).to eq(user)
    end
  end

  describe "#add!" do
    include_context "with released and unreleased episodes"

    it "adds without formats, merges names and preserves the original added date" do
      entry = manager.add!(movie).first
      original_date = entry.created_at
      manager.add!(movie, formats: [" Blu-ray ", "blu-RAY", "Digital", " VHS ", "vhs"])
      manager.add!(movie)
      expect(user.collection_items.count).to eq(1)
      expect(entry.reload.created_at).to eq(original_date)
      expect(CollectionItem.includes(:formats).find(entry.id).formats.map(&:name)).to match_array(["Blu-ray", "Digital", "VHS"])
      expect(user.collection_formats.pluck(:name)).to eq(["VHS"])
    end

    it "does not modify history, watchlists or standard stacks" do
      user.watchlist!.add!(movie)
      stack = user.stacks.create!(name: "Favourites")
      stack.add!(movie)
      history = HistoryItem.create!(user:, item: movie)
      manager.add!(movie, formats: ["Digital"])
      manager.remove_formats!(movie, formats: [CollectionFormat.common.find_by!(name: "Digital")])
      manager.remove_all!(movie)
      expect(history.reload).to be_persisted
      expect(user.watchlisted?(movie)).to be(true)
      expect(stack.stack_items.count).to eq(1)
    end

    it "rejects unreleased and undated titles without creating formats" do
      [nil, Date.tomorrow].each do |date|
        movie.update_columns(release_date: date)
        expect { manager.add!(movie, formats: ["VHS"]) }.to raise_error(ArgumentError)
      end
      expect(user.collection_items).to be_empty
      expect(user.collection_formats).to be_empty
    end

    it "rolls back ownership and custom formats when a format is invalid" do
      expect { manager.add!(movie, formats: ["VHS", " "]) }.to raise_error(ArgumentError)
      expect(user.collection_items).to be_empty
      expect(user.collection_formats).to be_empty
    end

    it "rejects another user's custom formats" do
      other = FactoryBot.create(:user)
      format = other.collection_formats.create!(name: "VHS")
      expect { manager.add!(movie, formats: [format]) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(user.collection_items).to be_empty
    end

    it "requires a user and a valid scope" do
      expect { described_class.new(nil).add!(movie) }.to raise_error(ArgumentError)
      expect { manager.add!(movie, scope: :invalid) }.to raise_error(ArgumentError)
    end

    it "uses owned-only scope without owning missing episodes, then merges an all-episode addition" do
      manager.add!(first, formats: ["Digital"])
      manager.add!(season, scope: :owned, formats: ["Blu-ray"])
      expect(user.collection_items.pluck(:item_id)).to eq([first.id])
      expect(manager.status_for(season)).to eq(:partial)
      manager.add!(show, formats: ["Blu-ray"])
      expect(user.collection_items.pluck(:item_id)).to match_array([first.id, second.id])
      expect(user.collection_items.includes(:formats).find_by!(item: first).formats.map(&:name)).to match_array(["Digital", "Blu-ray"])
      expect(manager.statuses_for([show, season, future, special])).to eq(show => :completed, season => :completed, future => :none, special => :none)
    end

    it "does not create unused formats for an empty owned-only selection" do
      manager.add!(season, scope: :owned, formats: ["VHS"])
      expect(user.collection_formats).to be_empty
      expect(user.collection_items).to be_empty
    end

    it "accepts existing format ids and models without duplicating assignments" do
      common = CollectionFormat.common.first!
      custom = user.collection_formats.create!(name: "VHS")
      manager.add!(movie, formats: [common.id, custom, custom.id])
      expect(CollectionItemFormat.count).to eq(2)
    end

    it "rejects unsupported records and unsupported format values" do
      [nil, User.new, Movie.new].each do |record|
        expect { manager.add!(record) }.to raise_error(ArgumentError)
      end
      expect { manager.add!(movie, formats: [{}]) }.to raise_error(ArgumentError)
      expect(user.collection_items).to be_empty
    end

    it "rejects a nonpersisted owner" do
      expect { described_class.new(User.new).add!(movie) }.to raise_error(ArgumentError)
    end
  end

  describe "#remove_formats!" do
    include_context "with released and unreleased episodes"

    it "leaves ownership intact when removing a format across a show" do
      manager.add!(show, formats: ["VHS"])
      manager.add!(special, formats: ["VHS"])
      format = user.collection_formats.find_by!(name: "VHS")
      manager.remove_formats!(show, formats: [format.id])
      expect(user.collection_items.count).to eq(3)
      expect(user.collection_items.includes(:formats).find_by!(item: first).formats).to be_empty
      expect(format.reload).to be_persisted
      manager.remove_formats!(special, formats: [format.id])
      expect(CollectionFormat.exists?(format.id)).to be(false)
      expect(manager.status_for(show)).to eq(:completed)
    end

    it "keeps other formats and makes repeat removal harmless" do
      manager.add!(movie, formats: ["Blu-ray", "Digital"])
      blu_ray = CollectionFormat.common.find_by!(name: "Blu-ray")
      2.times { manager.remove_formats!(movie, formats: [blu_ray.id]) }
      expect(user.collection_items.includes(:formats).find_by!(item: movie).formats.map(&:name)).to eq(["Digital"])
    end

    it "rejects another user's custom format without changing ownership" do
      manager.add!(movie, formats: ["Digital"])
      other = FactoryBot.create(:collection_format)
      expect { manager.remove_formats!(movie, formats: [other]) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(CollectionItemFormat.count).to eq(1)
    end

    it "rejects invalid records and missing owners" do
      expect { manager.remove_formats!(nil, formats: []) }.to raise_error(ArgumentError)
      expect { described_class.new(nil).remove_formats!(movie, formats: []) }.to raise_error(ArgumentError)
    end
  end

  describe "#remove_all!" do
    include_context "with released and unreleased episodes"

    it "excludes specials from show removals but supports their season explicitly" do
      manager.add!(show, formats: ["Blu-ray"])
      manager.add!(specials, formats: ["VHS"])
      manager.remove_all!(show)
      expect(user.collection_items.pluck(:item_id)).to eq([special.id])
      expect(manager.status_for(show)).to eq(:none)
      expect(manager.status_for(specials)).to eq(:completed)
      manager.remove_all!(specials)
      expect(user.collection_items).to be_empty
      expect(user.collection_formats).to be_empty
    end

    it "keeps reused custom formats until their last ownership is removed" do
      episode = FactoryBot.create(:episode)
      manager.add!(movie, formats: ["VHS"])
      manager.add!(episode, formats: ["VHS"])
      format = user.collection_formats.first
      manager.remove_all!(movie)
      expect(format.reload).to be_persisted
      manager.remove_all!(episode)
      expect(CollectionFormat.exists?(format.id)).to be(false)
      expect(CollectionFormat.common.count).to eq(4)
    end

    it "does not remove another user's ownership or formats" do
      other = FactoryBot.create(:user)
      described_class.new(other).add!(movie, formats: ["VHS"])
      manager.add!(movie, formats: ["Digital"])
      2.times { manager.remove_all!(movie) }
      expect(other.collection_items.count).to eq(1)
      expect(other.collection_formats.count).to eq(1)
      expect(user.collection_items).to be_empty
    end

    it "rejects invalid records and missing owners" do
      expect { manager.remove_all!(nil) }.to raise_error(ArgumentError)
      expect { described_class.new(nil).remove_all!(movie) }.to raise_error(ArgumentError)
    end
  end

  describe "#status_for" do
    include_context "with released and unreleased episodes"

    it "does not own newly released episodes automatically" do
      manager.add!(show)
      future.update!(original_air_date: Date.today)
      expect(manager.status_for(show)).to eq(:partial)
      expect(user.collection_items.exists?(item: future)).to be(false)
    end

    it "returns none, partial, and completed independently of formats" do
      expect(manager.status_for(show)).to eq(:none)
      manager.add!(first)
      expect(manager.status_for(show)).to eq(:partial)
      manager.add!(show)
      expect(manager.status_for(show)).to eq(:completed)
      expect(manager.status_for(movie)).to eq(:none)
      manager.add!(movie)
      expect(manager.status_for(movie)).to eq(:completed)
    end
  end

  describe "#statuses_for" do
    include_context "with released and unreleased episodes"

    it "returns none for visitors" do
      expect(described_class.new(nil).statuses_for([movie])).to eq(movie => :none)
    end

    it "accepts nil, an empty list, or one record" do
      expect(manager.statuses_for(nil)).to eq({})
      expect(manager.statuses_for([])).to eq({})
      expect(manager.statuses_for(movie)).to eq(movie => :none)
    end

    it "calculates mixed records and ignores other users' ownership" do
      described_class.new(FactoryBot.create(:user)).add!(movie)
      manager.add!(first)
      expect(manager.statuses_for([movie, first, second, season, show, nil])).to eq(
        movie => :none, first => :completed, second => :none, season => :partial, show => :partial
      )
    end

    it "does not mark a container with no eligible episodes completed" do
      empty_show = FactoryBot.create(:show)
      expect(manager.statuses_for([empty_show])).to eq(empty_show => :none)
    end
  end
end
