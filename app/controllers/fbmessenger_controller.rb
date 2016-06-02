require 'open-uri'
require 'json'


class FbmessengerController < ApplicationController
    protect_from_forgery with: :null_session # CSRF対策無効化
    
    ACCESS_TOKEN = ENV['FB_ACCESS_TOKEN']
    
    def callback
      
      # 最初の認証
      # if params["hub.verify_token"] == "arai0806"
      #     render json: params["hub.challenge"]
      # else
      #     render json: "Error, wrong validation token"
      # end
        
        #POSTパラメータの取得
        @message = params["entry"][0]["messaging"][0]
        
        #送信先URIの設定
        @endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token="+ACCESS_TOKEN
        
        #ユーザIDの取得
        @sender = @message["sender"]["id"]
        
        #ユーザ情報URI
        @user_uri= "https://graph.facebook.com/v2.6/"+@sender+"?fields=first_name,last_name,profile_pic,locale,timezone,gender&access_token="+ACCESS_TOKEN
        
        @gifts=Gift.order("created_at DESC").limit(2)
        
        #ユーザの発言かどうかの判定
        if @message.include?("message") then
    
          #ユーザの発言
          
          #ユーザの発言取得
          @text = @message["message"]["text"]
    
          messageData={
              "attachment":{
                "type":"template",
                "payload":{
                  "template_type":"button",
                  "text":"どうやってギフトを決める?",
                  "buttons":[
                    {
                      "type":"postback",
                      "title":"QUESTION",
                      "subtitle":"できる？",
                      "payload":"QUESTION"
                    },
                    {
                      "type":"postback",
                      "title":"RANDOM",
                      "subtitle":"できる？",
                      "payload":"RANDOM"
                    }
                  ]
                }
              }
          }
          
          
          # messageData = {
          #   "attachment": {
          #     "type": "template",
          #     "payload": {
          #       "template_type": "generic",
          #       "elements": [{
          #         "title": @gifts[0].name ,
          #         "subtitle": "Element #1 of an hscroll",
          #         "image_url": "https://mocca-giftfinder.herokuapp.com/gifts/"+@gifts[0].id.to_s+"/img",
          #         "buttons": [{
          #           "type": "web_url",
          #           "url": @gifts[0].url ,
          #           "title": "こちらから！"
          #         }, {
          #           "type": "postback",
          #           "title": "Postback",
          #           "payload": "Payload for first element in a generic bubble",
          #         }],
          #       },{
          #         "title": @gifts[1].name,
          #         "subtitle": "Element #2 of an hscroll",
          #         "image_url": "https://mocca-giftfinder.herokuapp.com/gifts/"+@gifts[1].id.to_s+"/img",
          #         "buttons": [{
          #           "type": "web_url",
          #           "url": @gifts[1].url ,
          #           "title": "こちらから！"
          #         }, {
          #           "type": "postback",
          #           "title": "いい！",
          #           "payload": "1",
          #         },{
          #           "type": "postback",
          #           "title": "びみょ！",
          #           "payload": "2",
          #         }],
          #       }]
          #     }
          #   }
          # }
        
        sendData(messageData)
        
        else
        
          if @message.include?("postback") then
            
            #ユーザからのPOSTBACK
            
            #PAYLOADの取得
            @payload = @message["postback"]["payload"]
            
            #ユーザデータの取得
            userData=getUserData()
            
            @text=userData["last_name"]+userData["first_name"]+"さん"+@payload+"ですね？"
            
            messageData = {text: @text}
            
            sendData(messageData)
          
          else
            
            
          end
        
        end
       
        #MissingTemplate回避 
        render :nothing => true, status: :ok
    end
    
    private
    
    #データ送信関数
    def sendData(messageData)
      request_content = {recipient: {id: @sender},
                            message: messageData
                         }
      content_json = request_content.to_json
      RestClient.post(@endpoint_uri, content_json, {
            'Content-Type' => 'application/json; charset=UTF-8'
          }){ |response, request, result, &block|
            p response
            p request
            p result
          }
    end
    
    #ユーザデータの取得関数
    def getUserData()
      response = open(@user_uri)
      data = response.read
      userData = JSON.parse(data)
      return userData
    end

end
