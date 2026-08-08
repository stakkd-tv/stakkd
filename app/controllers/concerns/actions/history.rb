module Actions
  module History
    extend ActiveSupport::Concern

    def add_to_history
      record.add_to_history!(current_user, consumed_at: resolve_consumed_at)
      render json: {success: true}, status: 200
    rescue
      render json: {success: false, errors: ["Could not add #{record.class.to_s.downcase} to history"]}, status: 422
    end

    private

    def resolve_consumed_at
      case params[:consumed_at_type]
      when "now"
        Time.current
      when "date"
        params[:consumed_at].presence
      when "release_date"
        :release_date
      when "unknown"
        nil
      else
        raise ArgumentError, "Invalid consumed_at_type: #{params[:consumed_at_type]}"
      end
    end
  end
end
