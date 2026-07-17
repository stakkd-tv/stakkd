class SearchController < ApplicationController
  TABS = {
    movies: {klass: Movie, query_by: "translated_title,original_title,alternative_names", collection: "Movie", image_type: :poster, fallback: "2:3.png"},
    shows: {klass: Show, query_by: "translated_title,original_title,alternative_names", collection: "Show", image_type: :poster, fallback: "2:3.png"},
    people: {klass: Person, query_by: "original_name,translated_name,aka", collection: "Person", image_type: :image, fallback: "2:3.png"},
    companies: {klass: Company, query_by: "name", collection: "Company", image_type: :logo, fallback: "1:1.png", aspect: "aspect-square"},
    users: {klass: User, query_by: "username", collection: "User", image_type: :avatar, fallback: "user.png", aspect: "aspect-square"}
  }

  def index
    results = execute_multi_search
    unless results.is_a?(Array)
      @tabs_with_results = TABS.keys.map { |tab| {tab: tab.to_s, initial_results: [], count: 0} }
      return
    end

    @tabs_with_results = results.zip(TABS.keys).map do |result, tab|
      hits = result["hits"].to_a
      result_ids = hits.map { it["document"]["id"] }
      klass = TABS[tab][:klass]
      initial_results = klass.where(id: result_ids).map {
        image_type = TABS[tab][:image_type]
        args = image_type == :avatar ? {use_fallback: false} : {variant: :medium, use_fallback: false}
        image = image_type ? it.send(image_type, **args) : nil
        {poster_path: image ? url_for(image) : nil, title: it.to_s, slug: it.slug, aspect: TABS[tab][:aspect]}
      }
      {
        tab: tab.to_s,
        initial_results:,
        count: result["found"] || 0,
        fallback: TABS[tab][:fallback]
      }
    end.sort_by { |hash| -hash[:count] }
  end

  def show
    # TODO: Load more
  end

  private

  def execute_multi_search
    searches = TABS.values.map { {collection: "#{it[:collection]}_#{Rails.env}", query_by: it[:query_by]} }
    multi_search_params = {
      searches: searches
    }
    common_search_params = {q: params[:q], per_page: ApplicationController::GLOBAL_PER_PAGE}
    response = Typesense.client.multi_search.perform(multi_search_params, common_search_params)
    response["results"]
  rescue
    # TODO: Log failure
    nil
  end
end
