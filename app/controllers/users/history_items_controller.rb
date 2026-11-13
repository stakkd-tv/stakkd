class Users::HistoryItemsController < Users::BaseController
  before_action :require_same_user

  def destroy
    @user.history_items.find(params[:id]).destroy!

    respond_to do |format|
      format.html { redirect_to user_history_index_path(@user), status: :see_other }
      format.json { render json: {success: true} }
    end
  end
end
