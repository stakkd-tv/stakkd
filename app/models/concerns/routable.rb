module Routable
  extend ActiveSupport::Concern

  def ordered_related_records = [self]

  def route_name
    ordered_related_records.map { it.model_name.param_key }.join("_")
  end

  def related_records
    ordered_related_records.map do |record|
      [record.model_name.param_key.to_sym, record]
    end.to_h
  end

  def records_for_polymorphic_paths
    ordered_related_records.to_h do |record|
      if record == self
        [:id, record]
      else
        [:"#{record.model_name.param_key}_id", record]
      end
    end
  end

  def records_for_polymorphic_paths_with_full_id
    records_for_polymorphic_paths.transform_keys do |key|
      next :"#{model_name.param_key}_id" if key == :id
      key
    end
  end
end
