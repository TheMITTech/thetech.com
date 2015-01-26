json.array!(@article_lists) do |article_list|
  json.extract! article_list, :id, :name, :piece_id
  json.url article_list_url(article_list, format: :json)
end
