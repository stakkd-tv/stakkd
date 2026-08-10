module ApplicationHelper
  def format_runtime(object)
    RuntimeFormatter.new(object).format
  end

  def safe_trace
    return unless @error
    @error.backtrace
      .take(12)
      .map do |line|
        line
          .gsub(Rails.root.to_s, "[APP]") # strip app root
          .gsub(
            %r{.*?/gems/[^/]+/gems/([^/]+)/(.*)},
            '[GEMS]/\1/\2'
          )
      end
  end

  def polymorphic_history_path(record, action)
    record_type = record.related_records.keys.reverse.join("_")
    send("#{action}_#{record_type}_path", *record.records_for_polymorphic_paths)
  end
end
