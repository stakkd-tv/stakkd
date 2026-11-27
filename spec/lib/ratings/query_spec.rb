require "rails_helper"

RSpec.describe Ratings::Query do
  let(:user) { FactoryBot.create(:user) }

  def rate(item = FactoryBot.create(:movie), score: 8, changed_at: Time.current)
    FactoryBot.create(:rating, user:, item:, score:, updated_at: changed_at)
  end

  def fetch_ratings(params = {}, per_page: 24)
    described_class.new(user, params).fetch(per_page:)
  end

  describe "#initialize" do
    it "defaults to all media and scores, recently rated first, with dates visible" do
      query = described_class.new(user)
      expect(query.to_params).to eq(hidden_media_types: [], score: nil, sort: "recent", hide_dates: false)
      expect(query).to be_show_dates
    end

    it "normalizes filters and ignores unsupported values" do
      query = described_class.new(user, hidden_media_types: ["Movie", "Movie", "Unknown"], score: "8.5", sort: "unknown")
      expect(query.to_params).to eq(hidden_media_types: ["Movie"], score: nil, sort: "recent", hide_dates: false)
    end
  end

  describe "#hidden_media_types" do
    it "defaults to no hidden types" do
      expect(described_class.new(user).hidden_media_types).to eq([])
    end

    it "accepts all four supported types" do
      query = described_class.new(user, hidden_media_types: %w[Movie Show Season Episode])
      expect(query.hidden_media_types).to eq(%w[Movie Show Season Episode])
    end

    it "accepts a single value and removes unsupported types and duplicates" do
      expect(described_class.new(user, hidden_media_types: "Movie").hidden_media_types).to eq(["Movie"])
      query = described_class.new(user, hidden_media_types: %w[Episode Unknown Episode Show])
      expect(query.hidden_media_types).to eq(%w[Episode Show])
    end
  end

  describe "#score" do
    it "accepts each whole-number score as a string or integer" do
      (1..10).each do |score|
        expect(described_class.new(user, score:).score).to eq(score.to_s)
        expect(described_class.new(user, score: score.to_s).score).to eq(score.to_s)
      end
    end

    it "treats a missing, blank or invalid score as All" do
      [nil, "", "all", "unknown", 0, 11, 8.5, "08", [8]].each do |score|
        expect(described_class.new(user, score:).score).to be_nil
      end
    end
  end

  describe "#sort" do
    it "accepts each supported ordering" do
      %w[recent oldest highest lowest].each do |sort|
        expect(described_class.new(user, sort:).sort).to eq(sort)
      end
    end

    it "falls back to recent for a missing, blank or unsupported ordering" do
      [nil, "", "unknown"].each do |sort|
        expect(described_class.new(user, sort:).sort).to eq("recent")
      end
    end
  end

  describe "#to_params" do
    it "serializes normalized filters, sorting and date preferences for navigation" do
      query = described_class.new(user, hidden_media_types: ["Show"], score: 8, sort: "oldest", hide_dates: "true")
      expect(query.to_params).to eq(hidden_media_types: ["Show"], score: "8", sort: "oldest", hide_dates: true)
    end

    it "preserves the settings when used to construct another query" do
      query = described_class.new(user, score: 10, hide_dates: "true")
      expect(described_class.new(user, query.to_params).to_params).to eq(query.to_params)
    end
  end

  describe "#filtered?" do
    it "recognizes a media filter, score filter or their combination" do
      [{hidden_media_types: ["Movie"]}, {score: "8"}, {hidden_media_types: ["Show"], score: "8"}].each do |params|
        expect(described_class.new(user, params)).to be_filtered
      end
    end

    it "does not treat default settings, sorting, date preferences or invalid filters as filters" do
      [{}, {sort: "highest", hide_dates: "true"}, {score: "invalid", hidden_media_types: ["Unknown"]}].each do |params|
        expect(described_class.new(user, params)).not_to be_filtered
      end
    end
  end

  describe ".chronological_sorts" do
    it "identifies the two date orderings" do
      expect(described_class.chronological_sorts).to eq(%w[recent oldest])
    end
  end

  describe "#chronological?" do
    it "recognizes recent and oldest ratings" do
      %w[recent oldest].each do |sort|
        expect(described_class.new(user, sort:)).to be_chronological
      end
    end

    it "excludes both score orderings" do
      %w[highest lowest].each do |sort|
        expect(described_class.new(user, sort:)).not_to be_chronological
      end
    end
  end

  describe "#show_dates?" do
    it "shows dates by default in both date orderings" do
      %w[recent oldest].each do |sort|
        [nil, "false", false].each do |hide_dates|
          expect(described_class.new(user, sort:, hide_dates:)).to be_show_dates
        end
      end
    end

    it "honors a string or boolean hide preference in both date orderings" do
      %w[recent oldest].each do |sort|
        ["true", true].each do |hide_dates|
          expect(described_class.new(user, sort:, hide_dates:)).not_to be_show_dates
        end
      end
    end

    it "never shows dates for either score ordering" do
      %w[highest lowest].each do |sort|
        [nil, "false", "true"].each do |hide_dates|
          expect(described_class.new(user, sort:, hide_dates:)).not_to be_show_dates
        end
      end
    end
  end

  describe "#fetch" do
    it "returns only the requested owner's current ratings" do
      owned = rate
      FactoryBot.create(:rating, item: owned.item)
      FactoryBot.create(:movie)
      expect(fetch_ratings).to eq([[owned], nil])
    end

    it "includes all four media types and Specials as independent entries" do
      episode = FactoryBot.create(:episode)
      specials = episode.show.seasons.find_by!(number: 0)
      special_episode = FactoryBot.create(:episode, season: specials)
      ratings = [FactoryBot.create(:movie), episode.show, episode.season, episode, specials, special_episode].map { |item| rate(item) }
      expect(fetch_ratings.first).to contain_exactly(*ratings)
    end

    it "combines media types with the owner's exact score rather than community scores" do
      movie = rate
      episode = rate(FactoryBot.create(:episode))
      rate(FactoryBot.create(:show))
      rate(score: 7)
      FactoryBot.create(:rating, item: movie.item, score: 1)
      ratings, = fetch_ratings({hidden_media_types: %w[Show Season], score: "8"})
      expect(ratings).to contain_exactly(movie, episode)
    end

    it "returns an empty batch for an empty profile, no matching score or all types hidden" do
      expect(fetch_ratings).to eq([[], nil])
      rate
      expect(fetch_ratings({score: "1"})).to eq([[], nil])
      expect(fetch_ratings({hidden_media_types: %w[Movie Show Season Episode]})).to eq([[], nil])
    end

    it "continues listing saved ratings when release metadata becomes unknown" do
      rating = rate
      rating.item.update_columns(release_date: nil)
      expect(fetch_ratings).to eq([[rating], nil])
    end

    context "with ratings that share scores and timestamps" do
      let(:timestamp) { Time.zone.local(2026, 11, 20, 12, 0, 0, 123456) }
      let!(:first) { rate(score: 8, changed_at: timestamp - 3.days) }
      let!(:second) { rate(score: 8, changed_at: timestamp - 1.day) }
      let!(:third) { rate(score: 3, changed_at: timestamp - 1.day) }
      let!(:fourth) { rate(score: 10, changed_at: timestamp - 2.days) }
      let!(:fifth) { rate(score: 8, changed_at: second.updated_at) }

      {
        "recent" => %i[fifth third second fourth first],
        "oldest" => %i[first fourth second third fifth],
        "highest" => %i[fourth fifth second first third],
        "lowest" => %i[third fifth second first fourth]
      }.each do |sort, names|
        context "when sorting by #{sort}" do
          let(:expected) { names.map { |name| public_send(name) } }

          it "orders scores, change times and tied entries consistently" do
            expect(fetch_ratings({sort:}).first).to eq(expected)
          end

          it "pages through every entry once, including tied values and fractional seconds" do
            cursor = nil
            expected.each do |rating|
              ratings, cursor = fetch_ratings({sort:, after: cursor}, per_page: 1)
              expect(ratings).to eq([rating])
            end
            expect(cursor).to be_nil
          end

          it "keeps the saved boundary when its rating is removed" do
            _, cursor = fetch_ratings({sort:}, per_page: 1)
            expected.first.destroy!
            expect(fetch_ratings({sort:, after: cursor}, per_page: 1).first).to eq([expected.second])
          end

          it "keeps the saved boundary when its score and change time are updated" do
            _, cursor = fetch_ratings({sort:}, per_page: 1)
            expected.first.update!(score: 1)
            expect(fetch_ratings({sort:, after: cursor}, per_page: 1).first).to eq([expected.second])
          end
        end
      end

      it "preserves the active filters across batches" do
        filters = {score: "8", hidden_media_types: %w[Show Season Episode], hide_dates: "true"}
        ratings, cursor = fetch_ratings(filters, per_page: 1)
        expect(ratings).to eq([fifth])
        expect(fetch_ratings(filters.merge(after: cursor), per_page: 1).first).to eq([second])
      end

      it "ignores invalid or tampered cursors" do
        _, cursor = fetch_ratings({}, per_page: 1)
        ["invalid", "#{cursor}tampered"].each do |after|
          expect(fetch_ratings({after:}, per_page: 1).first).to eq([fifth])
        end
      end

      it "starts from the beginning when a cursor belongs to another ordering" do
        _, cursor = fetch_ratings({sort: "recent"}, per_page: 1)
        expect(fetch_ratings({sort: "highest", after: cursor}, per_page: 1).first).to eq([fourth])
      end
    end

    it "returns no cursor for a partial batch or an exactly full final batch" do
      rating = rate
      expect(fetch_ratings({}, per_page: 1)).to eq([[rating], nil])
      expect(fetch_ratings({}, per_page: 2)).to eq([[rating], nil])
    end

    it "returns an empty batch when remaining ratings are removed" do
      first = rate(changed_at: 1.day.ago)
      second = rate
      _, cursor = fetch_ratings({}, per_page: 1)
      first.destroy!
      expect(fetch_ratings({after: cursor}, per_page: 1)).to eq([[], nil])
      expect(second).to be_persisted
    end

    it "preloads card titles, nested routes and poster attachments for every media type" do
      episode = FactoryBot.create(:episode)
      season = episode.season
      show = season.show
      movie = FactoryBot.create(:movie)
      [movie, show, season].each do |item|
        item.posters.attach(io: File.open(Rails.root.join("spec/support/assets/300x450.png")), filename: "poster.png", content_type: "image/png")
      end
      [movie, show, season, episode].each { |item| rate(item) }
      ratings, = fetch_ratings

      queries = []
      subscriber = ->(event) { queries << event.payload[:sql] unless event.payload[:name] == "SCHEMA" }
      ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") do
        ratings.each do |rating|
          entry = RatingPresenter.new(rating)
          expect(entry.title).to be_present
          expect(entry.subtitle).to be_present
          expect(entry.poster).to be_a(ActiveStorage::VariantWithRecord)
          expect(entry.item.records_for_polymorphic_paths).to be_present
        end
      end
      expect(queries).to be_empty
    end
  end
end
