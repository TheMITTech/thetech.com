json.array!(@pieces) do |piece|
  json.extract! piece, :id, :web_template
  json.url piece_url(piece, format: :json)
end
