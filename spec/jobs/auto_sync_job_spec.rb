require "rails_helper"

RSpec.describe AutoSyncJob, type: :job do
  it "syncs all records" do
    expect(Sync::Base).to receive(:sync_all)
    AutoSyncJob.new.perform
  end
end
