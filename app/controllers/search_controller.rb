class SearchController < ApplicationController
  before_action :require_search_query
  before_action :set_search_presenter

  def index
    @tabs_with_results = @search_presenter.multi_search
  end

  def show
    return not_found unless @search_presenter.current_tab_valid?

    @page = @search_presenter.current_page
    @results, @has_more = @search_presenter.single_search

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def require_search_query
    redirect_back(fallback_location: root_path) unless params[:q].present?
  end

  def set_search_presenter
    @search_presenter = SearchPresenter.new(params)
  end
end
