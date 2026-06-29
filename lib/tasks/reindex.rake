namespace :reindex do
  desc "Reindex Movie, Show, Job, and Person models in Typesense"
  task models: :environment do
    models = [Movie, Show, Job, Person]

    models.each do |model|
      puts "Reindexing #{model.name}..."
      model.reindex!
    rescue => e
      puts "Failed to reindex #{model.name}: #{e.message}"
    end

    puts "Reindexing complete!"
  end
end
