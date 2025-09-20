require "rails_helper"

module Tabulator
  RSpec.describe ContentRatingsPresenter, type: :presenter do
    let(:cert) { FactoryBot.create(:certification, code: "ABC", country: FactoryBot.create(:country), media_type: "Movie") }
    let(:content_ratings) { FactoryBot.create_list(:content_rating, 1, certification: cert) }
    let(:presenter) { ContentRatingsPresenter.new(content_ratings) }

    describe "#table_data" do
      it "returns the fields for the ratings" do
        expect(presenter.table_data).to eq([
          {
            id: content_ratings.first.id,
            certification_id: content_ratings.first.certification.code,
            country_id: {label: content_ratings.first.certification.country.translated_name, value: content_ratings.first.certification.country.id}
          }
        ])
      end
    end

    describe "#column_defs" do
      it "returns the column definitions" do
        expect(presenter.column_defs).to eq([
          {title: "Certification", field: "certification_id", sorter: "string"},
          {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
        ])
      end
    end

    describe "#model_table_name" do
      it "returns the table name" do
        expect(presenter.model_table_name).to eq "content_rating"
      end
    end

    describe "#group_by" do
      it "returns country id" do
        expect(presenter.group_by).to eq "country_id"
      end
    end
  end
end
