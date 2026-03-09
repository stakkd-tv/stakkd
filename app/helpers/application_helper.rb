module ApplicationHelper
  def format_runtime(object)
    RuntimeFormatter.new(object).format
  end
end
