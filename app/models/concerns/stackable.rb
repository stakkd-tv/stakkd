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

  # TODO: Order stacks by number of likes
  def stacks_with_previews(page: 1)
    initial_stacks = stacks.order(created_at: :desc)
      .paginate(page: page, per_page: 3)
    stack_items = StackItem
      .where(stack_id: initial_stacks)
      .first_three_per_stack
      .includes(:item)
      .group_by(&:stack_id)

    with_previews = initial_stacks.to_h do |stack|
      [stack, stack_items.fetch(stack.id, [])]
    end
    [with_previews, initial_stacks.next_page]
  end
end
