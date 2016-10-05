namespace :chronic do
  desc "Regenerate ElasticSearch piece index. "
  task regenerate_es_index: :environment do
    start_time = Time.now
    Piece.import
    end_time = Time.now

    puts "Regenerated ElasticSearch piece index in #{end_time - start_time} seconds. "
    end

  desc "Generate pdf preview for last issue that doesn't have it"
  task generate_latest_issue_preview: :environment do
    start_time = Time.now
    i = Issue.find_by(pdf_preview_file_name: nil)
    i.save
    end_time = Time.now

    puts "Generated latest issue's pdf preview in #{end_time - start_time} seconds. "
  end

end
