require "faraday"
require "faraday_middleware"
require "json"
require "pp"

class LineClient
  END_POINT = "https://api.line.me"

  def initialize(channel_access_token, proxy = nil)
    @channel_access_token = channel_access_token
    @proxy = proxy
  end

  def post(path, data)
    client = Faraday.new(:url => END_POINT) do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
      conn.proxy @proxy
    end

    res = client.post do |request|
      request.url path
      request.headers = {
        'Content-type' => 'application/json',
        'Authorization' => "Bearer #{@channel_access_token}"
      }
      request.body = data
    end
    res
  end

  def reply(replyToken, text)

    messages = [
      {
        "type" => "text" ,
        "text" => text
      }
    ]

    body = {
      "replyToken" => replyToken ,
      "messages" => messages
    }
    post('/v2/bot/message/reply', body.to_json)
  end

end

# class LineClient
#   module ContentType
#     TEXT = 1
#     IMAGE = 2
#     VIDEO = 3
#     AUDIO = 4
#     LOCATION = 7
#     STICKER = 8
#     CONTACT = 10
#   end
#   module ToType
#     USER = 1
#   end

#   END_POINT = "https://trialbot-api.line.me"
#   TO_CHANNEL = 1383378250 # this is fixed value
#   EVENT_TYPE = "138311608800106203" # this is fixed value

#   def initialize(channel_id, channel_secret, channel_mid, proxy = nil)
#     @channel_id = channel_id
#     @channel_secret = channel_secret
#     @channel_mid = channel_mid
#     @proxy = proxy
#   end

#   def post(path, data)
#     client = Faraday.new(:url => END_POINT) do |conn|
#       conn.request :json
#       conn.response :json, :content_type => /\bjson$/
#       conn.adapter Faraday.default_adapter
#       conn.proxy @proxy
#     end

#     res = client.post do |request|
#       request.url path
#       request.headers = {
#           'Content-type' => 'application/json; charset=UTF-8',
#           'X-Line-ChannelID' => @channel_id,
#           'X-Line-ChannelSecret' => @channel_secret,
#           'X-Line-Trusted-User-With-ACL' => @channel_mid
#       }
#       request.body = data
#     end
#     res
#   end

#   def send(line_ids, message)
#     post('/v1/events', {
#         to: line_ids,
#         content: {
#             contentType: ContentType::TEXT,
#             toType: ToType::USER,
#             text: message
#         },
#         toChannel: TO_CHANNEL,
#         eventType: EVENT_TYPE
#     })
#   end
  
#   def sendImage(line_ids, url, imageurl)
#     post('/v1/events', {
#         to: line_ids,
#         content: {
#             contentType: ContentType::IMAGE,
#             toType: ToType::USER,
#             originalContentUrl: url,
#             previewImageUrl: imageurl
#         },
#         toChannel: TO_CHANNEL,
#         eventType: EVENT_TYPE
#     })
#   end
# end