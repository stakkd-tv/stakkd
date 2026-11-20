FactoryBot.define do
  factory :collection_item_format do
    collection_item
    association :collection_format, factory: [:collection_format, :common]
  end
end
