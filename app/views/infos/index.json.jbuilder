json.array!(@infos) do |info|
  json.extract! info, :id, :title, :content, :img, :img_content_type
  json.url info_url(info, format: :json)
end
