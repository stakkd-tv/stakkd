class Users::StacksController < Users::BaseController
  before_action :require_same_user, only: [:new, :create, :destroy]
  before_action :set_stack, only: [:show, :destroy]
  before_action :check_stack_privacy, only: [:show]

  # TODO: Edit stack

  def index
    @stacks_with_previews, @stacks_next_page = Stacks::WithPreviews
      .new(@user.stacks, user: current_user, per_page: 9)
      .fetch(page: params[:page])

    respond_to do |format|
      format.html
      format.turbo_stream if params[:page].present?
    end
  end

  # TODO: System specs for actions for each stack item
  def show
    @stack_items = @stack.stack_items.includes(item: [:show, :season]).limit(100)
    @watch_statuses = Manage::History.new(current_user).statuses_for(@stack_items.map(&:item))
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

  def destroy
    @stack.destroy
    respond_to do |format|
      format.html { redirect_to user_stacks_path(@user) }
      format.json { render json: {success: true} }
    end
  end

  private

  def stack_params
    params.require(:stack).permit(:name, :description, :private)
  end

  def set_stack
    @stack = @user.stacks.from_slug(params[:id])
  end

  def check_stack_privacy
    if @stack.private? && current_user != @user
      redirect_to user_path(@user), notice: "This stack is private."
    end
  end
end
