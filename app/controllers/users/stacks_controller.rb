class Users::StacksController < Users::BaseController
  before_action :require_same_user, only: [:new, :create]

  # TODO: Edit stack
  # TODO: Show stack
  # TODO: Delete stack

  def index
    @stacks_with_previews, @stacks_next_page = Stacks::WithPreviews
      .new(@user.stacks, user: current_user, per_page: 9)
      .fetch(page: params[:page])

    respond_to do |format|
      format.html
      format.turbo_stream if params[:page].present?
    end
  end

  def new
    @stack = current_user.stacks.new
  end

  def create
    @stack = current_user.stacks.new(stack_params)
    if @stack.save
      redirect_to user_stacks_path(@user), status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def stack_params
    params.require(:stack).permit(:name, :description, :private)
  end
end
