module Actions
  module Ratings
    extend ActiveSupport::Concern

    def set_rating
      rating = Manage::Ratings.new(current_user).set!(record, score: params[:score])
      render json: {score: rating.score}
    rescue Manage::Ratings::InvalidRating => error
      render json: {errors: [error.message]}, status: :unprocessable_content
    rescue ActiveRecord::RecordInvalid => error
      render json: {errors: error.record.errors.full_messages}, status: :unprocessable_content
    end

    def remove_rating
      Manage::Ratings.new(current_user).remove!(record)
      render json: {score: nil}
    end
  end
end
