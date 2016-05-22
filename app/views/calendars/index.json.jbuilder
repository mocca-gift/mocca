json.array!(@calendars) do |calendar|
  json.extract! calendar, :id, :month, :day, :name1, :name2, :name3
  json.url calendar_url(calendar, format: :json)
end
