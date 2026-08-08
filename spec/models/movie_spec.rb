require "rails_helper"
require_relative "shared_examples/slugify"
require_relative "shared_examples/has_imdb"
require_relative "shared_examples/has_galleries"
require_relative "shared_examples/history"

RSpec.describe Movie, type: :model do
  describe "associations" do
    it { should belong_to(:country) }
    it { should belong_to(:language) }
    it { should have_many(:alternative_names).dependent(:destroy) }
    it { should have_many(:cast_members).dependent(:destroy) }
    it { should have_many(:crew_members).dependent(:destroy) }
    it { should have_many(:genre_assignments).dependent(:destroy) }
    it { should have_many(:genres).through(:genre_assignments) }
    it { should have_many(:keyword_taggings).dependent(:destroy) }
    it { should have_many(:company_assignments).dependent(:destroy) }
    it { should have_many(:companies).through(:company_assignments) }
    it { should have_many(:releases).dependent(:destroy) }
    it { should have_many(:taglines).dependent(:destroy) }
    it { should have_many(:history_items).dependent(:destroy) }
    it { should have_one(:franchise_item).dependent(:destroy) }
    it { should have_one(:franchise).through(:franchise_item) }
  end

  describe "validations" do
    it { should validate_presence_of(:translated_title) }
    it { should validate_presence_of(:original_title) }
    it { should validate_presence_of(:runtime) }
    it { should validate_presence_of(:revenue) }
    it { should validate_presence_of(:budget) }
    it { should validate_inclusion_of(:status).in_array(Movie::STATUSES) }
  end

  it_behaves_like "a model with galleries", :movie, [:posters, :backgrounds, :logos, :videos]

  it_behaves_like "a model that can be added to history" do
    let(:record) { FactoryBot.create(:movie, :with_release_date) }
    let(:items_for_history) { [record] }
    let(:release_date) { record.release_date }
  end

  describe "before_validation :denormalize_release_date" do
    context "when there is a release" do
      it "sets release_date from release" do
        uk = FactoryBot.create(:country, code: "UK")
        cert_uk = FactoryBot.create(:certification, country: uk)
        movie = FactoryBot.create(:movie, country: uk)
        release = FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_uk, date: Date.today)
        movie.save # This line isn't needed due to callback on release model, but will keep for clarity
        expect(movie.release_date).to eq release.date
      end

      context "when the movie is part of a franchise (has a franchise item)" do
        it "updates the date stored on the franchise item" do
          uk = FactoryBot.create(:country, code: "UK")
          cert_uk = FactoryBot.create(:certification, country: uk)
          movie = FactoryBot.create(:movie, country: uk)
          release = FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_uk, date: Date.today)
          franchise_item = FactoryBot.create(:franchise_item, record: movie)
          # Reload release to clear its associated movie's in-memory association cache.
          # This ensures movie.franchise_item is queried from the DB rather than returning
          # the nil cached prior to franchise_item creation. This should not cause any real
          # world problems as Rails fetches fresh records on every request.
          release.reload
          expect(franchise_item.reload.date).to eq Date.today
          release.update!(date: Date.tomorrow)
          expect(franchise_item.reload.date).to eq Date.tomorrow
        end
      end
    end

    context "when there is no release" do
      it "does not set a release date" do
        movie = FactoryBot.create(:movie)
        movie.save
        expect(movie.release_date).to be_nil
      end
    end
  end

  it_behaves_like "a slugified model", :movie, :translated_title

  it_behaves_like "a model with imdb_id", Movie

  describe "#slug=" do
    it "sets the title_kebab" do
      movie = Movie.new
      movie.slug = "test"
      expect(movie.title_kebab).to eq "test"
    end
  end

  describe "#to_s" do
    it "returns the translated title" do
      expect(Movie.new(translated_title: "Test name").to_s).to eq "Test name"
    end
  end

  describe "#tagline" do
    it "returns the first tagline ordered by position" do
      movie = FactoryBot.create(:movie)
      FactoryBot.create(:tagline, record: movie, tagline: "Tagline 1")
      tagline2 = FactoryBot.create(:tagline, record: movie, tagline: "Tagline 2")
      tagline2.insert_at(1)
      expect(movie.tagline).to eq "Tagline 2"
    end

    it "returns nil when there are no taglines" do
      movie = FactoryBot.create(:movie)
      expect(movie.tagline).to be_nil
    end
  end

  describe "#release" do
    it "returns nil when there are no releases" do
      movie = FactoryBot.create(:movie)
      expect(movie.release).to be_nil
    end

    it "returns nil when there is no theatrical or digital release for the country" do
      uk = FactoryBot.create(:country, code: "UK")

      us = FactoryBot.create(:country, code: "US")
      cert_us = FactoryBot.create(:certification, country: us)

      movie = FactoryBot.create(:movie, country: uk)
      FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_us)
      FactoryBot.create(:release, movie:, type: Release::DIGITAL, certification: cert_us)
      expect(movie.release).to be_nil
    end

    it "returns the digital when there is no theatrical release for the country" do
      uk = FactoryBot.create(:country, code: "UK")
      cert_uk = FactoryBot.create(:certification, country: uk)

      us = FactoryBot.create(:country, code: "US")
      cert_us = FactoryBot.create(:certification, country: us)

      movie = FactoryBot.create(:movie, country: uk)
      FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_us)
      release = FactoryBot.create(:release, movie:, type: Release::DIGITAL, certification: cert_uk)
      expect(movie.release).to eq release
    end

    it "returns the theatrical release for the country even when there is a digital release" do
      uk = FactoryBot.create(:country, code: "UK")
      cert_uk = FactoryBot.create(:certification, country: uk)

      us = FactoryBot.create(:country, code: "US")
      cert_us = FactoryBot.create(:certification, country: us)

      movie = FactoryBot.create(:movie, country: uk)
      FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_us)
      release = FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_uk)
      FactoryBot.create(:release, movie:, type: Release::DIGITAL, certification: cert_uk)
      expect(movie.release).to eq release
    end

    it "returns the first release when there is both a theatrical and digital release" do
      uk = FactoryBot.create(:country, code: "UK")
      cert_uk = FactoryBot.create(:certification, country: uk)

      movie = FactoryBot.create(:movie, country: uk)
      FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_uk, date: Date.tomorrow)
      release = FactoryBot.create(:release, movie:, type: Release::DIGITAL, certification: cert_uk, date: Date.today)
      expect(movie.release).to eq release
    end
  end

  describe "#release_dates_for_country" do
    it "returns the release dates for that country ordered by date" do
      uk = FactoryBot.create(:country, code: "UK")
      cert_uk = FactoryBot.create(:certification, country: uk)

      us = FactoryBot.create(:country, code: "US")
      cert_us = FactoryBot.create(:certification, country: us)

      movie = FactoryBot.create(:movie, country: uk)
      FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_us)
      release1 = FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_uk, date: Date.new(2022, 2, 1))
      release2 = FactoryBot.create(:release, movie:, type: Release::DIGITAL, certification: cert_uk, date: Date.new(2022, 1, 1))
      expect(movie.release_dates_for_country).to eq [release2, release1]
    end
  end

  describe "#directors" do
    context "when the movie has a director" do
      it "returns the directors" do
        director = FactoryBot.build(:crew_member, job: FactoryBot.build(:job, name: Job::DIRECTOR))
        movie = FactoryBot.create(:movie, crew_members: [director])
        expect(movie.directors).to eq [director]
      end
    end

    context "when the movie does not have a director" do
      it "returns an empty array" do
        movie = FactoryBot.create(:movie)
        expect(movie.directors).to eq []
      end
    end
  end

  describe "#year" do
    it "returns the year of the release date" do
      uk = FactoryBot.create(:country, code: "UK")
      cert_uk = FactoryBot.create(:certification, country: uk)
      movie = FactoryBot.create(:movie, country: uk)
      release = FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_uk, date: Date.today)
      movie.save # This line isn't needed due to callback on release model, but will keep for clarity
      expect(movie.year).to eq release.date.year
    end

    it "returns nil when the release date is nil" do
      movie = FactoryBot.create(:movie)
      expect(movie.year).to be_nil
    end
  end
end
