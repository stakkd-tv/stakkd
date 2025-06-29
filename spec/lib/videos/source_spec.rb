require "rails_helper"

module Videos
  RSpec.describe Source do
    describe ".for" do
      context "when source is valid" do
        Video::SOURCES.each do |source|
          it "returns the correct object for #{source}" do
            expect(Source.for(source, "")).to be_a("Videos::#{source}".constantize)
          end
        end
      end

      context "when source is invalid" do
        it "returns the base object" do
          expect(Source.for("invalid", "")).to be_a(Source)
        end
      end
    end

    describe "#title" do
      subject { Source.new("").title }
      it { should be_nil }
    end

    describe "#thumbnail_url" do
      subject { Source.new("").thumbnail_url }
      it { should be_nil }
    end

    describe "#video_url" do
      subject { Source.new("").video_url }
      it { should be_nil }
    end

    describe "#icon" do
      subject { Source.new("").icon }
      it { should eq "fa-galactic-republic" }
    end
  end
end
