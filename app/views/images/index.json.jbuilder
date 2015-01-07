json.array!(@images) do |image|
  json.extract! image, :id, :caption, :attribution
  json.url image_url(image, format: :json)
end
