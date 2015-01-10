json.array!(@authors) do |author|
  json.extract! author, :id, :name, :email, :bio
  json.url author_url(author, format: :json)
end
