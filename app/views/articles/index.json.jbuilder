json.array!(@articles) do |article|
  json.extract! article, :id, :title, :byline, :dateline, :chunks
  json.url article_url(article, format: :json)
end
