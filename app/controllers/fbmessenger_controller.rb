class FbmessengerController < ApplicationController
    protect_from_forgery with: :null_session
    
    def callback
      
      if params["hub.verify_token"] == "arai0806"
          render json: params["hub.challenge"]
      else
          render json: "Error, wrong validation token"
      end
    #     token = "EAAWFQPfGEBkBAFx7AxBpdVK4VViIEsDcpRV5fXRV1jmWmg5lg9Kj8rF2Le0nUnAfNnrLFbS5xDuEuZAwoI9xZCQ7CUf9HOvSFQaVAcF0gxen3OixKVSvVulUJxOrbP1VHmZCRNfk1qAAbYS2k88S08rUllOjbwDXSV1jXeEQH8ZAn26sdieP"

    #     message = params["entry"][0]["messaging"][0]
    
    #     if message.include?("message") then
    
    #       #ユーザーの発言
    
    #       @sender = message["sender"]["id"]
    #       @text = message["message"]["text"]
    
    #       endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token="+token
    #       request_content = {recipient: {id: @sender},
    #                         message: {text: @text}
    #                         }
    
    #       content_json = request_content.to_json
    
    #       RestClient.post(endpoint_uri, content_json, {
    #         'Content-Type' => 'application/json; charset=UTF-8'
    #       }){ |response, request, result, &block|
    #         p response
    #         p request
    #         p result
    #       }
    #     else
    #       #botの発言
    #     end
    end

end
