module Stackable
  extend ActiveSupport::Concern

  def user_stacks(user)
    return [] unless user
    user.stacks.includes(:stack_items).where(stack_items: {item: self}).pluck(:id)
  end
end
