require "rails_helper"

module Tabulator
  RSpec.describe VideosPresenter, type: :presenter do
    before do
      youtube = instance_double(
        Videos::YouTube,
        title: "Never Gonna Give You Up",
        thumbnail_url: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
        video_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        icon: "fa-youtube"
      )
      allow(Videos::Source).to receive(:for).and_return(youtube)
      @videos = FactoryBot.create_list(:video, 1)
      @presenter = VideosPresenter.new(@videos)
    end

    describe "#table_data" do
      it "returns the fields for the videos" do
        expect(@presenter.table_data).to eq([
          {
            id: @videos.first.id,
            source: "<div class='flex justify-center items-center'><i class='fa-brands fa-youtube text-lg'></i></div>",
            source_key: @videos.first.source_key,
            title: @videos.first.url,
            name: "Never Gonna Give You Up",
            type: "Trailer"
          }
        ])
      end
    end

    describe "#column_defs" do
      it "returns the column definitions" do
        expect(@presenter.column_defs).to eq([
          {title: "", field: "source", headerSort: false, formatter: "html", width: 50, resizable: false},
          {title: "Key", field: "source_key", headerSort: false, width: 125, resizable: false},
          {title: "Title", field: "title", sorter: "string", formatter: "link", formatterParams: {labelField: "name"}, minWidth: 200},
          {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
        ])
      end
    end

    describe "#model_table_name" do
      it "returns the table name" do
        expect(@presenter.model_table_name).to eq "video"
      end
    end

    describe "#group_by" do
      it "returns true" do
        expect(@presenter.group_by).to eq "type"
      end
    end
  end
end
