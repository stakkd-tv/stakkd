module StackConcerns
  extend ActiveSupport::Concern

  def stack_show
    @sorting_method = params[:sort].presence_in(Stack::SORTING_METHODS) || @stack.sorting_method
    @sorting_direction = params[:direction].presence_in(Stack::SORTING_DIRECTIONS) || @stack.sorting_direction
    @filter_options = Stack::ALLOWED_ITEM_TYPES.map { [it.pluralize, it] }
    @selected_filters = params[:filters] || []
    filter_params = (params[:filters] || Stack::ALLOWED_ITEM_TYPES) & Stack::ALLOWED_ITEM_TYPES
    @reorderable = @sorting_method == "position" && @sorting_direction == "asc" && @selected_filters == []

    # TODO: Pagination on stack items. Need to figure out how this would interact with drag and drop sorting...
    @stack_items = @stack.stack_items
      .where(item_type: filter_params)
      .public_send("ordered_by_#{@sorting_method}", @sorting_direction.to_sym)
      .includes(item: [:show, :season])
      .map { StackItemPresenter.new(it) }
    items = @stack_items.map(&:item)
    @watch_statuses = Manage::History.new(current_user).statuses_for(items)
    @watchlisted_items = current_user&.watchlisted_items_from(items) || []
  end
end
