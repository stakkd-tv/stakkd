class RatingPresenter
  attr_reader :rating

  delegate :item, to: :rating

  def initialize(rating)
    @rating = rating
  end

  def title
    case item
    when Season then item.show.translated_title
    when Episode then item.season.show.translated_title
    else item.translated_title
    end
  end

  def subtitle
    case item
    when Season then season_subtitle
    when Episode then "S#{item.season.number}E#{item.number} · #{item.translated_name}"
    else item.class.name
    end
  end

  def poster
    # Episodes have landscape backgrounds; use their season's poster in this grid.
    record = item.is_a?(Episode) ? item.season : item
    record.poster(variant: :small)
  end

  private

  def season_subtitle
    label = "Season #{item.number}"
    return item.translated_name if item.specials? || item.translated_name == label

    "#{label} · #{item.translated_name}"
  end
end
