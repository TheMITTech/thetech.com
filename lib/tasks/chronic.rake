namespace :chronic do
  desc "Regenerate ElasticSearch piece index. "
  task regenerate_es_index: :environment do
    start_time = Time.now
    Piece.import
    end_time = Time.now

    puts "Regenerated ElasticSearch piece index in #{end_time - start_time} seconds. "
  end

end
