require "ostruct"

class Pagination::Episodes
  include Rails.application.routes.url_helpers

  attr_reader :episode, :season, :show

  def initialize(episode, season, show)
    @episode = episode
    @season = season
    @show = show
  end

  def next_item = @next_item ||= episode.next_episode

  def previous_item = @previous_item ||= episode.previous_episode

  def next_item_path = show_season_episode_path(next_item, season_id: season, show_id: show)

  def previous_item_path = show_season_episode_path(previous_item, season_id: season, show_id: show)

  def items
    @items ||= season
      .ordered_episodes
      .map {
        ::OpenStruct.new(
          name: "Episode #{it.number}",
          path: show_season_episode_path(it, season_id: season, show_id: show),
          selected: it == episode
        )
      }
  end
end
