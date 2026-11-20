module Collections
  class Dialog
    def initialize(user, record)
      @user = user
      @record = record
    end

    def as_json(*)
      items = @record.tracking_items.to_a
      entries = @user.collection_items.where(item: items)
      counts = CollectionItemFormat.where(collection_item: entries).group(:collection_format_id).count
      {
        title: @record.to_s,
        container: @record.is_a?(Show) || @record.is_a?(Season),
        excludes_specials: @record.is_a?(Show),
        total: items.size,
        owned: entries.count,
        can_add: !!@record.released? && items.any?,
        formats: CollectionFormat.available_to(@user).order(:name).map do |format|
          {id: format.id, name: format.name, count: counts.fetch(format.id, 0)}
        end,
        affected_items: Manage::Collection.new(@user).statuses_for(affected_records).transform_keys do |record|
          "#{record.class.polymorphic_name}:#{record.id}"
        end
      }
    end

    private

    def affected_records
      case @record
      when Show
        [@record, *Season.where(show_id: @record.id), *@record.tracking_items]
      when Season
        [@record, Show.find(@record.show_id), *@record.tracking_items]
      when Episode
        season = Season.find(@record.season_id)
        [@record, season, Show.find(season.show_id)]
      else
        [@record]
      end
    end
  end
end
