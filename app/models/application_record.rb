class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  self.strict_loading_by_default = true

  def param_name = :"#{model_name.param_key}_id"
end
