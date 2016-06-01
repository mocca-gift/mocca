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
        @gifts=Gift.order("created_at DESC").limit(2)
    
        if message.include?("message") then
    
          #ユーザーの発言
    
          @sender = message["sender"]["id"]
          @text = message["message"]["text"]
    
          endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token="+token
          
          @messageData = {
            "attachment": {
              "type": "template",
              "payload": {
                "template_type": "generic",
                "elements": [{
                  "title": @gifts[0].name ,
                  "subtitle": "Element #1 of an hscroll",
                  "image_url": "https://mocca-giftfinder.herokuapp.com/gifts/"+@gifts[0].id.to_s+"/img",
                  "buttons": [{
                    "type": "web_url",
                    "url": @gifts[0].url ,
                    "title": "こちらから！"
                  }, {
                    "type": "postback",
                    "title": "Postback",
                    "payload": "Payload for first element in a generic bubble",
                  }],
                },{
                  "title": @gifts[1].name,
                  "subtitle": "Element #2 of an hscroll",
                  "image_url": "https://mocca-giftfinder.herokuapp.com/gifts/"+@gifts[1].id.to_s+"/img",
                  "buttons": [{
                    "type": "web_url",
                    "url": @gifts[1].url ,
                    "title": "こちらから！"
                  }, {
                    "type": "postback",
                    "title": "いい！",
                    "payload": "1",
                  },{
                    "type": "postback",
                    "title": "びみょ！",
                    "payload": "2",
                  }],
                }]
              }
            }
          }
        
        request_content = {recipient: {id: @sender},
                            message: @messageData
                            }
    
          content_json = request_content.to_json
    
          RestClient.post(endpoint_uri, content_json, {
            'Content-Type' => 'application/json; charset=UTF-8'
          }){ |response, request, result, &block|
            p response
            p request
            p result
          }
        else
          if message.include?("postback") then
            @sender = message["sender"]["id"]
            @text = message["postback"]["payload"]
            endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token="+token
            request_content = {recipient: {id: @sender},
                            message: @text
                            }
    
          content_json = request_content.to_json
    
          RestClient.post(endpoint_uri, content_json, {
            'Content-Type' => 'application/json; charset=UTF-8'
          })
            
          else
          end
        end
        
        render :nothing => true, status: :ok
    end

end
