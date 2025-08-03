json.array! @jobs.take(200) do |job|
  json.value job.id
  json.label job.name
  json.image_url nil
end
