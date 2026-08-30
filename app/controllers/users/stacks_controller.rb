class Users::StacksController < Users::BaseController
  # TODO: Edit stack
  # TODO: New stack
  # TODO: Show stack
  # TODO: Delete stack

  def index
    @stacks_with_previews, @stacks_next_page = Stacks::WithPreviews
      .new(@user.stacks, user: current_user, per_page: 9)
      .fetch(page: params[:page])
  end
end
