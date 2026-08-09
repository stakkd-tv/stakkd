module History
  extend ActiveSupport::Concern

  def history_manager_for(user) = Manage::History.new(user)

  def add_to_history!(user, consumed_at:) = history_manager_for(user).add!(self, consumed_at:)

  def items_for_history = raise NotImplementedError

  def history_release_date = raise NotImplementedError
end
