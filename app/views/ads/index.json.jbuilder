json.array!(@ads) do |ad|
  json.extract! ad, :id, :name, :start_date, :end_date, :type
  json.url ad_url(ad, format: :json)
end
