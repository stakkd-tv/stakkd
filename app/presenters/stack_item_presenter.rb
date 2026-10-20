class StackItemPresenter < SimpleDelegator
  def sorting_detail(sorting_method)
    formatter = :"format_#{sorting_method}"
    send(formatter) if respond_to?(formatter, true)
  end

  private

  def format_added_at
    "Added: #{added_at.strftime("%b %d, %Y %H:%M")}"
  end

  def format_position
    "Position #<span class='stackItem-position'>#{position.to_i}</span>".html_safe
  end

  def format_release_date
    date = item.release_date&.strftime("%B %d, %Y") || "TBA"
    "Release: #{date}"
  end

  def format_runtime
    "Runtime: #{RuntimeFormatter.new(item).format}"
  end
end
