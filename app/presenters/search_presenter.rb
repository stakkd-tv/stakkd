class SearchPresenter
  TABS = {
    movies: {
      klass: Movie,
      query_by: "translated_title,original_title,alternative_names",
      collection: "Movie",
      image: ->(record) { record.poster(variant: :medium) }
    },
    shows: {
      klass: Show,
      query_by: "translated_title,original_title,alternative_names",
      collection: "Show",
      image: ->(record) { record.poster(variant: :medium) }
    },
    people: {
      klass: Person,
      query_by: "original_name,translated_name,aka",
      collection: "Person",
      image: ->(record) { record.image(variant: :medium) }
    },
    companies: {
      klass: Company,
      query_by: "name",
      collection: "Company",
      image: ->(record) { record.logo(variant: :medium) },
      aspect: "aspect-square"
    },
    users: {
      klass: User,
      query_by: "username",
      collection: "User",
      image: ->(record) { record.avatar },
      aspect: "aspect-square"
    }
  }

  def initialize(params)
    @params = params
  end

  def multi_search
    results = execute_multi_search
    return TABS.keys.map { |tab| {tab: tab.to_s, initial_results: [], count: 0} } unless results.is_a?(Array)

    results.zip(TABS.keys).map do |result, tab_name|
      tab = tab_info(tab_name)
      hits = result["hits"].to_a
      result_ids = hits.map { |hit| hit["document"]["id"]&.to_i }

      {
        tab: tab_name.to_s,
        initial_results: present_records_by_ids(tab[:klass], result_ids, tab),
        count: result["found"] || 0
      }
    end.sort_by { |tab| -tab[:count] }
  end

  def single_search
    tab = tab_info(params[:id])
    return [], false unless tab
    search_results = execute_single_search
    results = search_results.map { result_hash(it, tab) }
    has_more_pages = search_results.any? && search_results.next_page.present?
    [results, has_more_pages]
  end

  def current_tab_valid?
    tab_info(params[:id]).present?
  end

  def current_page = (params[:page] || 1).to_i

  private

  attr_reader :params, :current_tab

  def result_hash(result, tab)
    {
      image: tab[:image].call(result),
      title: result.to_s,
      slug: result.slug,
      aspect: tab[:aspect]
    }
  end

  def tab_info(tab)
    TABS[tab&.to_sym]
  end

  def execute_single_search
    tab = tab_info(params[:id])
    klass = tab[:klass]
    klass.search(
      params[:q],
      tab[:query_by],
      {
        page: current_page,
        per_page: ApplicationController::GLOBAL_PER_PAGE
      }
    )
  rescue => e
    log_search_error(e)
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
  rescue => e
    log_search_error(e)
    nil
  end

  # Orders results by relevance as returned by Typesense
  def present_records_by_ids(klass, ids, tab)
    records_by_id = klass.where(id: ids).index_by(&:id)

    ids.filter_map do |id|
      record = records_by_id[id]
      result_hash(record, tab) if record
    end
  end

  def log_search_error(exception)
    Rails.logger.error("Failed to execute search for query #{params[:q]}: #{exception.message}")
  end
end
