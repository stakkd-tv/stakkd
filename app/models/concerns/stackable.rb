module Stackable
  extend ActiveSupport::Concern

  included do
    has_many :stack_items, as: :item, dependent: :destroy
    has_many :stacks, through: :stack_items
  end

  def user_stacks(user)
    return [] unless user
    user.stacks.includes(:stack_items).where(stack_items: {item: self}).pluck(:id)
  end
end
