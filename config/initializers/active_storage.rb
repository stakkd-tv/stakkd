Rails.configuration.to_prepare do
  ActiveStorage::Blob.include BlobExtension
  ActiveStorage::Attachment.include HasBlob
  ActiveStorage::VariantWithRecord.include HasBlob
end
