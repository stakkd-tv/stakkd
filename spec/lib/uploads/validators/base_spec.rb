require "rails_helper"

module Uploads::Validators
  RSpec.describe Base do
    describe ".for" do
      context "when the validator class exists" do
        it "returns the correct validator" do
          expect(Base.for(klass: Person, field: :images)).to eq PersonImagesValidator
        end
      end

      context "when the validator class does not exist" do
        it "returns the NoOpValidator" do
          expect(Base.for(klass: Person, field: :bogus)).to eq NoOpValidator
        end
      end
    end
  end
end
