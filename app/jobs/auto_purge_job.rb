class AutoPurgeJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ActiveStorage::Blob.unattached.each(&:purge_later)
  end
end
