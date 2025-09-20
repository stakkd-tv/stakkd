class ContentRatingsController < ApplicationController
  before_action :require_authentication
  before_action :set_show
  before_action :set_content_rating, only: [:destroy]

  def index
    @table_presenter = Tabulator::ContentRatingsPresenter.new(@show.content_ratings.includes(certification: :country))
  end

  def create
    @content_rating = @show.content_ratings.new(content_rating_params)
    if @content_rating.save
      redirect_to show_content_ratings_path(@show), notice: "Successfully added certification."
    else
      redirect_to show_content_ratings_path(@show), alert: "Certification could not be added."
    end
  end

  def destroy
    @content_rating.destroy!
    redirect_to show_content_ratings_path(@show), status: :see_other
  end

  private

  def set_show
    @show = Show.from_slug(params.expect(:show_id))
  end

  def set_content_rating
    @content_rating = @show.content_ratings.find(params.expect(:id))
  end

  def content_rating_params
    params.expect(content_rating: [:certification_id])
  end
end
