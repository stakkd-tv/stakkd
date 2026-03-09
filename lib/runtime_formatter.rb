class RuntimeFormatter
  def initialize(object)
    @remaining_minutes = object.runtime
  end

  def format
    days = extract_from_runtime(1440)
    hours = extract_from_runtime(60)
    minutes = @remaining_minutes

    formatted_output = ""
    formatted_output += "#{days}d " if days > 0
    formatted_output += "#{hours}h " if hours > 0
    formatted_output += "#{@remaining_minutes}m"
    formatted_output
  end

  private

  def extract_from_runtime(minutes_to_cap)
    return 0 if @remaining_minutes < minutes_to_cap

    remainder = @remaining_minutes % minutes_to_cap
    minutes = @remaining_minutes - remainder
    @remaining_minutes = remainder
    minutes / minutes_to_cap
  end
end
