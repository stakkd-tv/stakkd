require "rails_helper"

module Sync
  RSpec.describe Base do
    describe ".sync_all" do
      it "syncs all subclasses" do
        expect_any_instance_of(Genres).to receive(:start)
        expect_any_instance_of(Countries).to receive(:start)
        expect_any_instance_of(Languages).to receive(:start)
        Base.sync_all
      end
    end
  end
end
