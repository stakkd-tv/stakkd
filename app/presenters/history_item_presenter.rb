class HistoryItemPresenter
  attr_reader :history_item

  TITLE_MAP = {
    Episode => ->(item) { item.show.translated_title },
    Movie => ->(item) { item.translated_title }
  }

  SUBTITLE_MAP = {
    Episode => ->(item) { "S#{item.season.number}E#{item.number} - #{item.translated_name}" }
  }

  delegate :consumed_at, to: :history_item
  delegate :item, to: :history_item

  def initialize(history_item)
    @history_item = history_item
  end

  def title
    title_lamda = TITLE_MAP[item.class]
    title_lamda&.call(item) || item.to_s
  end

  def subtitle
    subtitle_lamda = SUBTITLE_MAP[item.class]
    subtitle_lamda&.call(item) || item.class.to_s.humanize
  end

  def formatted_consumed_at
    consumed_at&.strftime("%B %-d, %Y %-I:%M %p") || "Unknown date"
  end
end
