namespace :incopy do
  desc "TODO"
  task :export_article, [:article_id] => [:environment] do |t, args|
    article = Article.find(args[:article_id].to_d)

    puts article.incopy_tagged_text
  end

end
