json.array! @people.take(200) do |person|
  json.value person.id
  json.label person.translated_name
  json.image_url person.image_url
end
