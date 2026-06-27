FactoryBot.define do
  factory :search_document do
    original_title { "MyString" }
    translated_title { "MyString" }
    aliases { "MyText" }
    searchable { nil }
  end

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
