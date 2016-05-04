json.array!(@gifts) do |gift|
  json.extract! gift, :id, :name, :url, :img, :img_content_type
  json.url gift_url(gift, format: :json)
end
