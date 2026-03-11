require "rails_helper"

RSpec.describe Release, type: :model do
  describe "associations" do
    it { should belong_to(:movie) }
    it { should belong_to(:certification) }
    it { should have_one(:country).through(:certification) }
  end

  describe "validations" do
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:date) }
    it { should validate_inclusion_of(:type).in_array(Release::TYPES) }
  end

  describe "after_save :trigger_movie_update" do
    context "when the release is considered the main release for the movie" do
      it "should update the movie's release_date" do
        uk = FactoryBot.create(:country, code: "UK")
        cert_uk = FactoryBot.create(:certification, country: uk)
        movie = FactoryBot.create(:movie, country: uk)
        release = FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_uk, date: Date.today)
        expect(movie.reload.release_date).to eq release.date
      end
    end

    context "when the release is not considered the main release for the movie" do
      it "does not update the movies release date" do
        uk = FactoryBot.create(:country, code: "UK")
        cert_uk = FactoryBot.create(:certification, country: uk)
        movie = FactoryBot.create(:movie, country: uk)
        first_release = FactoryBot.create(:release, movie:, type: Release::PHYSICAL, certification: cert_uk, date: Date.yesterday)
        expect(movie.reload.release_date).to be_nil
        release = FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert_uk, date: Date.today)
        expect(movie.reload.release_date).to eq release.date
        future_release = FactoryBot.create(:release, movie:, type: Release::TV, certification: cert_uk, date: Date.today)
        expect(movie.reload.release_date).to eq release.date
      end
    end
  end

  describe ".inheritance_column" do
    it "should be empty" do
      expect(Release.inheritance_column).to be_nil
    end
  end
end
