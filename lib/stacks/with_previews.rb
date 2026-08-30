module Stacks
  class WithPreviews
    def initialize(stacks, per_page: 3)
      @stacks = stacks
      @per_page = per_page
    end

    # TODO: Order stacks by number of likes
    def fetch(page: 1)
      initial_stacks = @stacks.order(created_at: :desc)
        .paginate(page: page, per_page: @per_page)
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
end
