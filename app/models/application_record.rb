class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def related_records
    {self.class.to_s.downcase.to_sym => self}
  end
end
