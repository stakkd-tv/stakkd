FactoryBot.define do
  after :build do |record|
    if record.is_a? ActiveRecord::Base
      record.strict_loading! false
    end
  end

  after :stub do |record|
    if record.is_a? ActiveRecord::Base
      record.strict_loading! false
    end
  end
end
