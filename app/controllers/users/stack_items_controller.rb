class Users::StackItemsController < Users::BaseController
  before_action :require_same_user
  before_action :set_stack
  before_action :set_stack_item

  def destroy
    @stack_item.destroy
    respond_to do |format|
      format.html { redirect_to user_stack_path(@stack, user_id: @stack.user) }
      format.json { render json: {success: true} }
    end
  end

  private

  def set_stack
    @stack = @user.stacks.from_slug(params[:stack_id])
  end

  def set_stack_item
    @stack_item = @stack.stack_items.find(params[:id])
  end
end
