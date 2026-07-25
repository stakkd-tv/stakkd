class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  self.strict_loading_by_default = true

  def self.collection_name
    "#{model_name}_#{Rails.env}#{ENV["TEST_ENV_NUMBER"]}"
  end

  def related_records
    {self.class.to_s.downcase.to_sym => self}
  end

  # ORDERING IS IMPORTANT HERE - records are ordered by depth
  def records_for_polymorphic_paths
    related_records.values
  end
end
