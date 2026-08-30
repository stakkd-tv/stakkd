module Actions
  module Stacks
    extend ActiveSupport::Concern

    def add_to_stack
      stack = current_user.stacks.includes(:stack_items).find_by(id: params[:stack_id])
      return render json: {success: false, errors: ["Stack not found"]}, status: 404 unless stack

      stack.add!(record)
      render json: {success: true, stacks_for_this_record: record.user_stacks(current_user)}
    rescue
      render json: {success: false, errors: ["Failed to add to stack"]}, status: 422
    end

    def create_and_add_to_stack
      stack = Stack.create(user: current_user, name: params[:stack_name])
      return render json: {success: false, errors: ["Could not create stack"]}, status: 422 unless stack.valid?

      stack.add!(record)
      render json: {success: true, stack: {id: stack.id, name: stack.name}, stacks_for_this_record: record.user_stacks(current_user)}
    rescue
      render json: {success: false, errors: ["Failed to add to stack"]}, status: 422
    end

    def remove_from_stack
      stack = current_user.stacks.includes(:stack_items).find_by(id: params[:stack_id])
      return render json: {success: false, errors: ["Stack not found"]}, status: 404 unless stack

      stack.remove!(record)
      render json: {success: true, stacks_for_this_record: record.user_stacks(current_user)}
    rescue
      render json: {success: false, errors: ["Failed to remove from stack"]}, status: 422
    end

    def load_more_top_stacks
      respond_to do |format|
        format.html { not_found }
        format.turbo_stream do
          @stacks_with_previews, @stacks_next_page = record.stacks_with_previews(page: params[:page], current_user:)
          @load_more_top_stacks_path = helpers.polymorphic_record_path(record, "load_more_top_stacks", page: @stacks_next_page)
          render "shared/stacks/more_results"
        end
      end
    end
  end
end
