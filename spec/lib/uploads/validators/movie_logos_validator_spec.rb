require "rails_helper"

module Uploads::Validators
  RSpec.describe MovieLogosValidator do
    let(:width) { 0 }
    let(:height) { 0 }
    let(:aspect_ratio) { 0 }
    let(:validator) { MovieLogosValidator.new(width:, height:, aspect_ratio:) }

    describe "width_valid?" do
      subject { validator.width_valid? }

      context "when the width is too small" do
        let(:width) { 399 }
        it { should eq false }
      end

      context "when the width is too big" do
        let(:width) { 3001 }
        it { should eq false }
      end

      context "when the width is on the smaller edge" do
        let(:width) { 400 }
        it { should eq true }
      end

      context "when the width is on the higher edge" do
        let(:width) { 3000 }
        it { should eq true }
      end
    end

    describe "height_valid?" do
      subject { validator.height_valid? }

      context "when the height is too small" do
        let(:height) { 399 }
        it { should eq false }
      end

      context "when the height is too big" do
        let(:height) { 3001 }
        it { should eq false }
      end

      context "when the height is on the smaller edge" do
        let(:height) { 400 }
        it { should eq true }
      end

      context "when the height is on the higher edge" do
        let(:height) { 3000 }
        it { should eq true }
      end
    end

    describe "aspect_ratio_valid?" do
      subject { validator.aspect_ratio_valid? }

      context "when the aspect ratio is correct" do
        let(:aspect_ratio) { 1.0 / 1.0 }
        it { should eq true }
      end

      context "when the aspect ratio is incorrect" do
        let(:aspect_ratio) { 1.01 / 1.0 }
        it { should eq false }
      end
    end

    describe "valid?" do
      it "validates the width" do
        allow(validator).to receive(:width_valid?).and_return(false)
        expect(validator.valid?).to eq false
        expect(validator.errors[:width]).to eq ["must be between 400px and 3000px"]
      end

      it "validates the height" do
        allow(validator).to receive(:height_valid?).and_return(false)
        expect(validator.valid?).to eq false
        expect(validator.errors[:height]).to eq ["must be between 400px and 3000px"]
      end

      it "validates the aspect ratio" do
        allow(validator).to receive(:aspect_ratio_valid?).and_return(false)
        expect(validator.valid?).to eq false
        expect(validator.errors[:aspect_ratio]).to eq ["must be 1:1"]
      end
    end
  end
end
