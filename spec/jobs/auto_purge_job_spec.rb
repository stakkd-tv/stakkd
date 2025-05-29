require "rails_helper"

RSpec.describe AutoPurgeJob, type: :job do
  it "purges all unattached images" do
    blob = instance_double(ActiveStorage::Blob)
    expect(ActiveStorage::Blob).to receive(:unattached).and_return([blob])
    expect(blob).to receive(:purge_later)
    AutoPurgeJob.new.perform
  end
end
