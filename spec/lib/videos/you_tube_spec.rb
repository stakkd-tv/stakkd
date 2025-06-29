require "rails_helper"

module Videos
  RSpec.describe YouTube do
    describe "#title" do
      subject { YouTube.new("abc").title }

      before do
        expect_any_instance_of(Google::Apis::YoutubeV3::YouTubeService).to receive(:list_videos).and_return(response)
      end

      context "when there are no results" do
        let(:response) { instance_double(Google::Apis::YoutubeV3::ListVideosResponse, items: []) }
        it { should be_nil }
      end

      context "when there are results" do
        let(:response) { instance_double(Google::Apis::YoutubeV3::ListVideosResponse, items: [instance_double(Google::Apis::YoutubeV3::Video, snippet: instance_double(Google::Apis::YoutubeV3::VideoSnippet, title: "Test Title"))]) }
        it { should eq "Test Title" }
      end
    end

    describe "#thumbnail_url" do
      subject { YouTube.new("abc").thumbnail_url }

      before do
        expect_any_instance_of(Google::Apis::YoutubeV3::YouTubeService).to receive(:list_videos).and_return(response)
      end

      context "when there are no results" do
        let(:response) { instance_double(Google::Apis::YoutubeV3::ListVideosResponse, items: []) }
        it { should be_nil }
      end

      context "when there are results" do
        let(:response) { instance_double(Google::Apis::YoutubeV3::ListVideosResponse, items: [instance_double(Google::Apis::YoutubeV3::Video, snippet: instance_double(Google::Apis::YoutubeV3::VideoSnippet, thumbnails: instance_double(Google::Apis::YoutubeV3::ThumbnailDetails, maxres: instance_double(Google::Apis::YoutubeV3::Thumbnail, url: "Test URL"))))]) }
        it { should eq "Test URL" }
      end
    end

    describe "#video_url" do
      subject { YouTube.new("abc").video_url }
      it { should eq "https://www.youtube.com/watch?v=abc" }
    end

    describe "#icon" do
      subject { YouTube.new("").icon }
      it { should eq "fa-youtube" }
    end
  end
end
