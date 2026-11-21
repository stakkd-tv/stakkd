module Collections
  class Query
    GROUP_TYPE = "CASE WHEN collection_items.item_type = 'Movie' THEN 'Movie' ELSE 'Show' END".freeze
    GROUP_ID = "COALESCE(movies.id, shows.id)".freeze
    GROUP_TITLE = "COALESCE(movies.translated_title, shows.translated_title)".freeze
    SORTS = {
      "recent" => "added_at DESC, group_type ASC, group_id ASC",
      "title" => "LOWER(title) ASC, group_type ASC, group_id ASC"
    }.freeze

    attr_reader :hidden_media_types, :format_ids, :sort

    def initialize(user, params = {})
      @user = user
      @hidden_media_types = Array(params[:hidden_media_types]) & %w[Movie Show]
      available_ids = CollectionFormat.available_to(user).pluck(:id).map(&:to_s)
      @format_ids = Array(params[:formats]).map(&:to_s) & [*available_ids, "none"]
      @sort = params[:sort].presence_in(SORTS.keys) || "recent"
    end

    def to_params = {hidden_media_types:, formats: format_ids, sort:}

    def filtered? = hidden_media_types.any? || format_ids.any?

    # Filter ownership first, then paginate display groups. Paging episode rows
    # before grouping would split shows and change their counts and sort dates.
    def fetch(page: 1, per_page: 24)
      groups = CollectionItem.from("(#{grouped_items.to_sql}) collection_items")
        .order(Arel.sql(SORTS.fetch(sort)))
        .paginate(page:, per_page:)

      [build_groups(groups.to_a), groups.next_page]
    end

    def entries_for(show)
      filtered_items.where(item_type: "Episode", seasons: {show_id: show.id})
    end

    def removal_counts_for(show)
      @user.collection_items.where(item_type: "Episode")
        .joins("INNER JOIN episodes ON episodes.id = collection_items.item_id")
        .where(item_id: show.episodes.released.select(:id))
        .group("episodes.season_id").count
    end

    def seasons_for(show)
      Season.where(id: entries_for(show).select("episodes.season_id"))
        .order(Arel.sql("CASE WHEN number = 0 THEN 1 ELSE 0 END, number ASC"))
    end

    private

    def grouped_items
      selection = <<~SQL
        #{GROUP_TYPE} AS group_type,
        #{GROUP_ID} AS group_id,
        #{GROUP_TITLE} AS title,
        MAX(collection_items.created_at) AS added_at,
        COUNT(*) AS owned_count,
        COUNT(*) FILTER (WHERE seasons.number = 0) AS specials_count,
        COUNT(*) FILTER (WHERE collection_items.id NOT IN (
          SELECT collection_item_id FROM collection_item_formats
        )) AS unspecified_count
      SQL
      filtered_items.select(Arel.sql(selection))
        .group(Arel.sql("#{GROUP_TYPE}, #{GROUP_ID}, #{GROUP_TITLE}"))
    end

    def build_groups(rows)
      movies = records_for(rows, Movie)
      shows = records_for(rows, Show)
      eligible_counts = Episode.released.joins(:season)
        .where(seasons: {show_id: shows.keys}).where.not(seasons: {number: 0})
        .group("seasons.show_id").count
      formats = format_counts_for(movies.keys, shows.keys)

      rows.map do |row|
        type, id = row[:group_type], row[:group_id]
        Group.new(
          record: (type == "Movie") ? movies.fetch(id) : shows.fetch(id),
          added_at: row[:added_at],
          owned_count: row[:owned_count],
          specials_count: row[:specials_count],
          unspecified_count: row[:unspecified_count],
          eligible_count: eligible_counts.fetch(id, 0),
          format_counts: formats.fetch([type, id], {})
        )
      end
    end

    def records_for(rows, type)
      ids = rows.select { it[:group_type] == type.polymorphic_name }.map { it[:group_id] }
      type.where(id: ids).with_attached_backgrounds.index_by(&:id)
    end

    def format_counts_for(movie_ids, show_ids)
      page_items = filtered_items.where(item_type: "Movie", item_id: movie_ids)
        .or(filtered_items.where(item_type: "Episode", seasons: {show_id: show_ids}))
      counts = page_items.joins(:formats)
        .group(Arel.sql(GROUP_TYPE), Arel.sql(GROUP_ID), "collection_formats.name").count
      counts.sort_by { |(_, _, name), _| name.downcase }.each_with_object({}) do |((type, id, name), count), result|
        (result[[type, id]] ||= {})[name] = count
      end
    end

    def filtered_items
      items = @user.collection_items
        .joins("LEFT JOIN movies ON collection_items.item_type = 'Movie' AND movies.id = collection_items.item_id")
        .joins("LEFT JOIN episodes ON collection_items.item_type = 'Episode' AND episodes.id = collection_items.item_id")
        .joins("LEFT JOIN seasons ON seasons.id = episodes.season_id")
        .joins("LEFT JOIN shows ON shows.id = seasons.show_id")
        .where(item_type: %w[Movie Episode] - hidden_media_types.map { (it == "Show") ? "Episode" : it })
      return items if format_ids.empty?

      assigned = CollectionItemFormat.where(collection_format_id: format_ids.excluding("none")).select(:collection_item_id)
      matches = items.where(id: assigned)
      if format_ids.include?("none")
        matches = matches.or(items.where.not(id: CollectionItemFormat.select(:collection_item_id)))
      end
      matches
    end
  end
end
