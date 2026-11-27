class Users::RatingsController < Users::BaseController
  PER_PAGE = 24

  def index
    @ratings_query = Ratings::Query.new(@user, params)
    @ratings, @next_cursor = @ratings_query.fetch(per_page: PER_PAGE)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
