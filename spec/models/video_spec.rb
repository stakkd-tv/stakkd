require "rails_helper"

RSpec.describe Video, type: :model do
  describe "associations" do
    it { should belong_to(:record) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:source) }
    it { should validate_presence_of(:source_key) }
    it { should validate_presence_of(:type) }
    it { should validate_inclusion_of(:source).in_array(Video::SOURCES) }
    it { should validate_inclusion_of(:type).in_array(Video::TYPES) }
  end

  describe "before_create #set_details_from_source" do
    it "should set the details from the source" do
      video = FactoryBot.build(:video, source: "YouTube", source_key: "abc123")
      youtube = instance_double(Videos::YouTube, title: "Test Video", thumbnail_url: "https://i.ytimg.com/vi/abc123/default.jpg")
      expect(Videos::YouTube).to receive(:new).with("abc123").and_return(youtube)
      video.save
      expect(video.reload.name).to eq("Test Video")
      expect(video.thumbnail_url).to eq("https://i.ytimg.com/vi/abc123/default.jpg")
    end
  end

  describe ".inheritance_column" do
    it "should be empty" do
      expect(Video.inheritance_column).to be_nil
    end
  end

  describe "#url" do
    it "should return the video url" do
      video = Video.new(source: "YouTube", source_key: "abc123")
      expect(video.url).to eq("https://www.youtube.com/watch?v=abc123")
    end
  end

  describe "#source_icon" do
    it "should return the video icon" do
      video = Video.new(source: "YouTube", source_key: "abc123")
      expect(video.source_icon).to eq("fa-youtube")
    end
  end
end
