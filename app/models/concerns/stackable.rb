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

    load_seasons_shows(stack_items)
    initial_stacks.to_h do |stack|
      [stack, stack_items.fetch(stack.id, [])]
    end
  end

  private

  # NOTE: This preloads the shows for any given seasons, this is because
  # we need the show to be loaded when accessing Season#to_s.
  # TODO: We shouldn't need to do this. Maybe we need to update the #to_s
  # method so that it does not have a dependency on the show, or have some
  # sort of denormalization.
  def load_seasons_shows(stack_items)
    items = stack_items.values.flatten.map(&:item)
    seasons = items.select { |item| item.is_a?(Season) }
    return unless seasons.any?
    ActiveRecord::Associations::Preloader.new(
      records: seasons,
      associations: :show
    ).call
  end
end
