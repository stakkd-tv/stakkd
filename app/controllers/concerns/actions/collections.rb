module Actions
  module Collections
    extend ActiveSupport::Concern

    def collection
      render json: collection_dialog
    end

    def add_to_collection
      permitted = params.permit(:scope, format_ids: [], custom_formats: [])
      scope = permitted.fetch(:scope, "all")
      raise ArgumentError, "Choose owned episodes or all released episodes" unless %w[all owned].include?(scope)

      formats = Array(permitted[:format_ids]).map(&:to_i) + Array(permitted[:custom_formats])
      Manage::Collection.new(current_user).add!(record, formats:, scope: scope.to_sym)
      render json: collection_dialog
    rescue ArgumentError, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => error
      render json: {errors: [error.message]}, status: :unprocessable_content
    end

    def remove_collection_formats
      ids = params.permit(format_ids: []).fetch(:format_ids, []).map(&:to_i)
      Manage::Collection.new(current_user).remove_formats!(record, formats: ids)
      render json: collection_dialog
    rescue ArgumentError, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => error
      render json: {errors: [error.message]}, status: :unprocessable_content
    end

    def remove_from_collection
      Manage::Collection.new(current_user).remove_all!(record)
      render json: collection_dialog
    end

    private

    def collection_dialog = ::Collections::Dialog.new(current_user, record).as_json
  end
end
