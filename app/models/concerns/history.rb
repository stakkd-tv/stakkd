module History
  extend ActiveSupport::Concern

  def history_manager_for(user) = Manage::History.new(user)

  def add_to_history!(user, consumed_at:) = history_manager_for(user).add!(self, consumed_at:)

  def remove_all_from_history(user) = history_manager_for(user).remove_all(self)

  def status_for(user) = history_manager_for(user).status_for(self)

  def items_for_history = raise NotImplementedError

  def history_release_date = raise NotImplementedError

  def history_status_items = raise NotImplementedError
end
