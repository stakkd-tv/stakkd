require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#format_runtime" do
    it "calls the runtime formatter with the object" do
      object = Movie.new
      formatter = instance_double(RuntimeFormatter, format: "30m")
      expect(RuntimeFormatter).to receive(:new).with(object).and_return(formatter)
      helper.format_runtime(object)
    end
  end

  describe "#polymorphic_record_path" do
    context "when record is a movie" do
      it "returns the correct path for the record" do
        record = FactoryBot.build_stubbed(:movie)
        expect(helper.polymorphic_record_path(record, "add_to_history")).to eq(add_to_history_movie_path(record))
      end

      context "with params" do
        it "returns the correct path for the record" do
          record = FactoryBot.build_stubbed(:movie)
          expect(helper.polymorphic_record_path(record, "add_to_history", page: 1)).to eq(add_to_history_movie_path(record, page: 1))
        end
      end
    end

    context "when record is a show" do
      it "returns the correct path for the record" do
        record = FactoryBot.build_stubbed(:show)
        expect(helper.polymorphic_record_path(record, "add_to_history")).to eq(add_to_history_show_path(record))
      end

      context "with params" do
        it "returns the correct path for the record" do
          record = FactoryBot.build_stubbed(:show)
          expect(helper.polymorphic_record_path(record, "add_to_history", page: 1)).to eq(add_to_history_show_path(record, page: 1))
        end
      end
    end

    context "when record is a season" do
      it "returns the correct path for the record" do
        record = FactoryBot.build_stubbed(:season)
        expect(helper.polymorphic_record_path(record, "add_to_history")).to eq(add_to_history_show_season_path(record.show, record))
      end

      context "with params" do
        it "returns the correct path for the record" do
          record = FactoryBot.build_stubbed(:season)
          expect(helper.polymorphic_record_path(record, "add_to_history", page: 1)).to eq(add_to_history_show_season_path(record.show, record, page: 1))
        end
      end
    end

    context "when record is an episode" do
      it "returns the correct path for the record" do
        show = FactoryBot.create(:show)
        season = FactoryBot.create(:season, show:)
        record = FactoryBot.create(:episode, season:)
        expect(helper.polymorphic_record_path(record, "add_to_history")).to eq(add_to_history_show_season_episode_path(show, season, record))
      end

      context "with params" do
        it "returns the correct path for the record" do
          show = FactoryBot.create(:show)
          season = FactoryBot.create(:season, show:)
          record = FactoryBot.create(:episode, season:)
          expect(helper.polymorphic_record_path(record, "add_to_history", page: 1)).to eq(add_to_history_show_season_episode_path(show, season, record, page: 1))
        end
      end
    end
  end
end
