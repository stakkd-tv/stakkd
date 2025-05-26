class AutoSyncJob < ApplicationJob
  queue_as :default

  def perform(*args) = Sync::Base.sync_all
end
