require "rails_helper"

module Uploads::Validators
  RSpec.describe PersonImagesValidator do
    let(:width) { 0 }
    let(:height) { 0 }
    let(:aspect_ratio) { 0 }
    let(:validator) { PersonImagesValidator.new(width:, height:, aspect_ratio:) }

    describe "width_valid?" do
      subject { validator.width_valid? }

      context "when the width is too small" do
        let(:width) { 299 }
        it { should eq false }
      end

      context "when the width is too big" do
        let(:width) { 2001 }
        it { should eq false }
      end

      context "when the width is on the smaller edge" do
        let(:width) { 300 }
        it { should eq true }
      end

      context "when the width is on the higher edge" do
        let(:width) { 2000 }
        it { should eq true }
      end
    end

    describe "height_valid?" do
      subject { validator.height_valid? }

      context "when the height is too small" do
        let(:height) { 449 }
        it { should eq false }
      end

      context "when the height is too big" do
        let(:height) { 3001 }
        it { should eq false }
      end

      context "when the height is on the smaller edge" do
        let(:height) { 450 }
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
        let(:aspect_ratio) { 2.0 / 3.0 }
        it { should eq true }
      end

      context "when the aspect ratio is incorrect" do
        let(:aspect_ratio) { 2.03 / 3.0 }
        it { should eq false }
      end
    end

    describe "valid?" do
      it "validates the width" do
        allow(validator).to receive(:width_valid?).and_return(false)
        expect(validator.valid?).to eq false
        expect(validator.errors[:width]).to eq ["must be between 300px and 2000px"]
      end

      it "validates the height" do
        allow(validator).to receive(:height_valid?).and_return(false)
        expect(validator.valid?).to eq false
        expect(validator.errors[:height]).to eq ["must be between 450px and 3000px"]
      end

      it "validates the aspect ratio" do
        allow(validator).to receive(:aspect_ratio_valid?).and_return(false)
        expect(validator.valid?).to eq false
        expect(validator.errors[:aspect_ratio]).to eq ["must be 2:3"]
      end
    end
  end
end
