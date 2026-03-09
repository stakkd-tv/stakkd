require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#format_runtime" do
    it "calls the runtime formatter with the object" do
      object = Movie.new
      formatter = instance_double(RuntimeFormatter, format: "30m")
      expect(RuntimeFormatter).to receive(:new).with(object).and_return(formatter)
      helper.format_runtime(object)
    end
  end
end
