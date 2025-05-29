require "rails_helper"

module Uploads::Validators
  RSpec.describe NoOpValidator do
    describe "#valid?" do
      it "always returns false and adds an error" do
        validator = NoOpValidator.new(width: 100, height: 300, aspect_ratio: 3.44)
        expect(validator.valid?).to eq false
        expect(validator.errors.full_messages).to eq ["Record is unknown"]

        validator = NoOpValidator.new(width: Float::INFINITY, height: Float::INFINITY, aspect_ratio: 1)
        expect(validator.valid?).to eq false
        expect(validator.errors.full_messages).to eq ["Record is unknown"]
      end
    end
  end
end
