namespace :chronic do
  desc "Regenerate ElasticSearch piece index. "
  task regenerate_es_index: :environment do
    Piece.import
  end

end
