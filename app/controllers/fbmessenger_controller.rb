class FbmessengerController < ApplicationController
    protect_from_forgery with: :null_session
    
    def callback
      
      # if params["hub.verify_token"] == "arai0806"
      #     render json: params["hub.challenge"]
      # else
      #     render json: "Error, wrong validation token"
      # end
        token = "EAAWFQPfGEBkBAEdKXCPOQ5zb28zMOeSKkZAvQjYnODIPOakcDpC92wlHWARJZA4COUu77bBzAhW4SW0ybdPLELIZC8d60EAwoMpv8DBQR1gaHiZA0WZCbhZBxDGXSOIwojLc51OCGHF9EUghwMHy4oZCV55nvU4iZBcxZAZAfEjr3jCCgedb4aZCoSa"

        message = params["entry"][0]["messaging"][0]
    
        if message.include?("message") then
    
          #ユーザーの発言
    
          @sender = message["sender"]["id"]
          @text = message["message"]["text"]
    
          endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token="+token
          request_content = {recipient: {id: @sender},
                            message: {text: @text}
                            }
    
          content_json = request_content.to_json
    
          RestClient.post(endpoint_uri, content_json, {
            'Content-Type' => 'application/json; charset=UTF-8'
          })
          # { |response, request, result, &block|
          #   p response
          #   p request
          #   p result
          # }
        else
          #botの発言
        end
        
        render :nothing => true, status: :ok
    end

end
