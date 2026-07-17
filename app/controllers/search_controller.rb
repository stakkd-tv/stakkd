class SearchController < ApplicationController
  TABS = {
    movies: {klass: Movie, query_by: "translated_title,original_title,alternative_names", collection: "Movie", image_type: :poster},
    shows: {klass: Show, query_by: "translated_title,original_title,alternative_names", collection: "Show", image_type: :poster},
    people: {klass: Person, query_by: "original_name,translated_name,aka", collection: "Person", image_type: :image},
    companies: {klass: Company, query_by: "name", collection: "Company", image_type: :logo, aspect: "aspect-square"},
    users: {klass: User, query_by: "username", collection: "User", image_type: :avatar, aspect: "aspect-square"}
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
        args = image_type == :avatar ? {} : {variant: :medium}
        image = it.send(image_type, **args)
        {image:, title: it.to_s, slug: it.slug, aspect: TABS[tab][:aspect]}
      }
      {
        tab: tab.to_s,
        initial_results:,
        count: result["found"] || 0
      }
    end.sort_by { |hash| -hash[:count] }
  end

  def show
    @tab = params[:id].to_sym
    tab_info = TABS[@tab]
    return render(status: :not_found) unless tab_info

    @page = (params[:page] || 1).to_i
    search_results = execute_single_search(tab_info, @page)
    @results = search_results.map {
      image_type = tab_info[:image_type]
      args = image_type == :avatar ? {} : {variant: :medium}
      image = it.send(image_type, **args)
      {image:, title: it.to_s, slug: it.slug, aspect: tab_info[:aspect]}
    }
    @has_more = search_results.next_page.present?

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def execute_single_search(tab, page)
    klass = tab[:klass]
    klass.search(
      params[:q],
      tab[:query_by],
      {
        page: page,
        per_page: ApplicationController::GLOBAL_PER_PAGE
      }
    )
  rescue
    # TODO: Log failure
    []
  end

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
