require "rails_helper"

RSpec.describe Collections::Query do
  let(:user) { FactoryBot.create(:user) }
  let(:show) { FactoryBot.create(:show, :with_premiere_date, translated_title: "Zebra") }
  let(:season) { show.seasons_without_specials.first }
  let(:episode) { season.episodes.first }
  let(:bluray) { FactoryBot.create(:collection_format, :common) }
  let(:digital) { FactoryBot.create(:collection_format, :common, name: "Digital") }

  def own(item, formats: [], added_at: Time.current)
    entry = FactoryBot.create(:collection_item, user:, item:, created_at: added_at)
    formats.each { |format| FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: format) }
    entry
  end

  def fetch_groups(params = {}, **pagination)
    described_class.new(user, params).fetch(**pagination)
  end

  describe "#initialize" do
    it "defaults to all media and formats in recently added order" do
      query = described_class.new(user)
      expect(query.to_params).to eq(hidden_media_types: [], formats: [], sort: "recent")
    end

    it "ignores unsupported filters and another user's custom format" do
      foreign_format = FactoryBot.create(:collection_format)
      query = described_class.new(user, sort: "invalid", hidden_media_types: ["Season"], formats: [foreign_format.id, "unknown"])
      expect(query.to_params).to eq(hidden_media_types: [], formats: [], sort: "recent")
    end
  end

  describe "#hidden_media_types" do
    it "retains only supported media types without duplicates" do
      query = described_class.new(user, hidden_media_types: ["Movie", "Movie", "Season"])
      expect(query.hidden_media_types).to eq(["Movie"])
    end
  end

  describe "#format_ids" do
    it "accepts common formats, the owner's formats and the no-format option" do
      custom_format = FactoryBot.create(:collection_format, user:)
      foreign_format = FactoryBot.create(:collection_format)
      query = described_class.new(user, formats: [bluray.id, custom_format.id, foreign_format.id, "none"])
      expect(query.format_ids).to eq([bluray.id.to_s, custom_format.id.to_s, "none"])
    end
  end

  describe "#sort" do
    it "retains an allowed ordering" do
      expect(described_class.new(user, sort: "title").sort).to eq("title")
    end
  end

  describe "#to_params" do
    it "serializes the active filters and ordering for navigation" do
      query = described_class.new(user, hidden_media_types: ["Movie"], formats: [bluray.id, "none"], sort: "title")
      expect(query.to_params).to eq(hidden_media_types: ["Movie"], formats: [bluray.id.to_s, "none"], sort: "title")
    end
  end

  describe "#filtered?" do
    it "recognizes either kind of filter" do
      expect(described_class.new(user, hidden_media_types: ["Movie"])).to be_filtered
      expect(described_class.new(user, formats: ["none"])).to be_filtered
    end

    it "does not treat sorting as a filter" do
      expect(described_class.new(user, sort: "title")).not_to be_filtered
    end
  end

  describe "#fetch" do
    it "groups episodes by show without splitting a show across pages" do
      own(episode, added_at: 1.day.ago)
      own(FactoryBot.create(:episode, season:, number: 2))
      own(FactoryBot.create(:movie), added_at: 2.days.ago)
      groups, next_page = fetch_groups({}, per_page: 1)
      expect(groups.map(&:record)).to eq([show])
      expect(groups.first.owned_count).to eq(2)
      expect(next_page).to eq(2)
      expect(fetch_groups({}, per_page: 1, page: 2).first.map { it.record.class }).to eq([Movie])
    end

    it "matches any selected format once per ownership entry and retains all its formats" do
      own(episode, formats: [bluray, digital])
      own(FactoryBot.create(:episode, season:, number: 2), formats: [digital])
      group = fetch_groups({formats: [bluray.id, digital.id]}).first.first
      expect(group.owned_count).to eq(2)
      expect(group.format_counts).to eq("Blu-ray" => 1, "Digital" => 2)
      group = fetch_groups({formats: [bluray.id]}).first.first
      expect(group.owned_count).to eq(1)
      expect(group.format_counts).to eq("Blu-ray" => 1, "Digital" => 1)
    end

    it "combines media and format filters, including entries without formats" do
      movie = FactoryBot.create(:movie)
      own(movie)
      own(episode, formats: [bluray])
      expect(fetch_groups({formats: ["none"]}).first.map(&:record)).to eq([movie])
      expect(fetch_groups({formats: ["none", bluray.id]}).first.size).to eq(2)
      expect(fetch_groups({hidden_media_types: ["Movie"], formats: [bluray.id]}).first.map(&:record)).to eq([show])
      expect(fetch_groups({hidden_media_types: ["Movie", "Show"]}).first).to eq([])
    end

    it "sorts shows by the newest matching episode rather than newer nonmatching episodes" do
      own(episode, formats: [bluray], added_at: 3.days.ago)
      own(FactoryBot.create(:episode, season:, number: 2), formats: [digital])
      movie = FactoryBot.create(:movie)
      own(movie, formats: [bluray], added_at: 1.day.ago)
      groups, = fetch_groups({formats: [bluray.id]})
      expect(groups.map(&:record)).to eq([movie, show])
      expect(groups.last.added_at).to be_within(1.second).of(3.days.ago)
    end

    it "sorts titles case insensitively with deterministic pagination" do
      movie = FactoryBot.create(:movie, translated_title: "apple")
      own(episode)
      own(movie)
      expect(fetch_groups({sort: "title"}).first.map(&:record)).to eq([movie, show])
    end

    it "keeps specials separate from regular ownership counts and eligible totals" do
      special = FactoryBot.create(:episode, season: show.seasons.find_by!(number: 0))
      own(special)
      FactoryBot.create(:episode, season:, number: 2, original_air_date: Date.tomorrow)
      FactoryBot.create(:episode, season:, number: 3, original_air_date: nil)
      group = fetch_groups.first.first
      expect(group.record).to eq(show)
      expect(group.regular_count).to eq(0)
      expect(group.specials_count).to eq(1)
      expect(group.unspecified_count).to eq(1)
      expect(group.eligible_count).to eq(1)
    end

    it "preserves added sorting when formats are edited or ownership is added repeatedly" do
      movie = FactoryBot.create(:movie, :with_release_date)
      old = own(movie, added_at: 3.days.ago)
      own(episode, added_at: 1.day.ago)
      Manage::Collection.new(user).add!(movie, formats: [bluray])
      expect(fetch_groups.first.map(&:record)).to eq([show, movie])
      expect(old.reload.created_at).to be_within(1.second).of(3.days.ago)
    end

    it "returns an empty page without a next page" do
      expect(fetch_groups).to eq([[], nil])
    end
  end

  describe "#entries_for" do
    it "only returns owned episodes matching the show and formats" do
      match = own(episode, formats: [bluray])
      own(FactoryBot.create(:episode, season:, number: 2), formats: [digital])
      own(FactoryBot.create(:episode), formats: [bluray])
      FactoryBot.create(:collection_item, item: episode)

      query = described_class.new(user, formats: [bluray.id])
      expect(query.entries_for(show)).to contain_exactly(match)
    end
  end

  describe "#seasons_for" do
    it "skips nonmatching seasons and places Specials after regular seasons" do
      own(episode, formats: [bluray])
      nonmatching = FactoryBot.create(:season, show:, number: 2)
      own(FactoryBot.create(:episode, season: nonmatching), formats: [digital])
      later_season = FactoryBot.create(:season, show:, number: 3)
      own(FactoryBot.create(:episode, season: later_season), formats: [bluray])
      specials = show.seasons.find_by!(number: 0)
      own(FactoryBot.create(:episode, season: specials), formats: [bluray])

      query = described_class.new(user, formats: [bluray.id])
      expect(query.seasons_for(show)).to eq([season, later_season, specials])
    end
  end

  describe "#removal_counts_for" do
    it "counts the owner's released episodes by season regardless of active filters" do
      own(episode)
      own(FactoryBot.create(:episode, season:, number: 2), formats: [digital])
      own(FactoryBot.create(:episode, season:, number: 3, original_air_date: Date.tomorrow))
      FactoryBot.create(:collection_item, item: FactoryBot.create(:episode, season:, number: 4))
      own(FactoryBot.create(:episode))
      specials = show.seasons.find_by!(number: 0)
      own(FactoryBot.create(:episode, season: specials))

      query = described_class.new(user, formats: [digital.id], hidden_media_types: ["Show"])
      expect(query.removal_counts_for(show)).to eq(season.id => 2, specials.id => 1)
    end
  end
end
