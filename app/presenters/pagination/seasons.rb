require "ostruct"

class Pagination::Seasons
  include Rails.application.routes.url_helpers

  attr_reader :season, :show

  def initialize(season, show)
    @season = season
    @show = show
  end

  def next_item = @next_item ||= season.next_season

  def previous_item = @previous_item ||= season.previous_season

  def next_item_path = show_season_path(next_item, show_id: show)

  def previous_item_path = show_season_path(previous_item, show_id: show)

  def items
    @items ||= show
      .ordered_seasons
      .map {
        ::OpenStruct.new(
          name: (it.number == 0) ? "Specials" : "Season #{it.number}",
          path: show_season_path(it, show_id: show),
          selected: it == season
        )
      }
  end
end
