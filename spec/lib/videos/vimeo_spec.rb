require "rails_helper"

module Videos
  RSpec.describe Vimeo do
    describe "#title" do
      subject { Vimeo.new("abc").title }

      before do
        expect(::Vimeo::Simple::Video).to receive(:info).and_return(response)
      end

      context "when there is no response" do
        let(:response) { "" }
        it { should be_nil }
      end

      context "when there are no results" do
        let(:response) { [] }
        it { should be_nil }
      end

      context "when there are results" do
        let(:response) { [{"title" => "Test Title"}] }
        it { should eq "Test Title" }
      end
    end

    describe "#thumbnail_url" do
      subject { Vimeo.new("abc").thumbnail_url }

      before do
        expect(::Vimeo::Simple::Video).to receive(:info).and_return(response)
      end

      context "when there is no response" do
        let(:response) { "" }
        it { should be_nil }
      end

      context "when there are no results" do
        let(:response) { [] }
        it { should be_nil }
      end

      context "when there are results" do
        let(:response) { [{"thumbnail_large" => "Test Thumbnail URL"}] }
        it { should eq "Test Thumbnail URL" }
      end
    end

    describe "#video_url" do
      subject { Vimeo.new("abc").video_url }
      it { should eq "https://vimeo.com/abc" }
    end

    describe "#icon" do
      subject { Vimeo.new("").icon }
      it { should eq "fa-vimeo" }
    end
  end
end
