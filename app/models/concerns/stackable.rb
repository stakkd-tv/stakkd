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

  def stacks_with_previews(current_user: nil, page: 1)
    Stacks::WithPreviews.new(stacks, user: current_user).fetch(page:)
  end
end
