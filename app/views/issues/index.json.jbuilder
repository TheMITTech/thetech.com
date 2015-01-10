json.array!(@issues) do |issue|
  json.extract! issue, :id, :number, :volume
  json.url issue_url(issue, format: :json)
end
