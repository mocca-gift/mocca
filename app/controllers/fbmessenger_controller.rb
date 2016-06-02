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
    
          messageData1={
              "attachment":{
                "type":"template",
                "payload":{
                  "template_type":"button",
                  "text":"どうやってギフトを決める?",
                  "buttons":[
                    {
                      "type":"postback",
                      "title":"QUESTION",
                      "payload":"QUESTION"
                    },
                    {
                      "type":"postback",
                      "title":"RANDOM",
                      "payload":"RANDOM"
                    }
                  ]
                }
              }
          }
          
          @text="QUESTION:\n質問でギフトを探す!\nRANDOM:\n運に任せてギフトを探す!"
          
          messageData2 = {text: @text}
          
          
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
        
          sendData(messageData1)
          sendData(messageData2)
        
        else
        
          if @message.include?("postback") then
            
            #ユーザからのPOSTBACK
            
            #PAYLOADの取得
            @payload = @message["postback"]["payload"]
            
            case @payload
            when "QUESTION" then
              #ユーザIDでトーク履歴取得
              @talk=Fbtalk.find_by(:user => @sender) || Fbtalk.create(:user => @sender, :answer => "", :qflowid => "")
              
              qflowid = @message["timestamp"].to_s
              
              @questions=Question.order("RANDOM()").limit(5)
              q_Array=[0,0,0,0,0]
              i=0
              @questions.each do |q|
                 q_Array[i] = q.id
                 i+=1
              end
              qarray=q_Array.join(",")
              
              @talk.update(:answer => "0,0,0,0,0",:question => qarray, :qflowid => qflowid)
              payload_yes = qflowid+","+@questions[0].id.to_s+",1"
              payload_no  = qflowid+","+@questions[0].id.to_s+",2"
              
              messageData1 = {text: "プレゼントを渡す相手を想像して答えてね" }
              messageData2 = {
                "attachment":{
                  "type":"template",
                  "payload":{
                    "template_type":"button",
                    "text": @questions[0].body,
                    "buttons":[
                      {
                        "type":"postback",
                        "title":"はい!",
                        "payload": payload_yes
                      },
                      {
                        "type":"postback",
                        "title":"いいえ!",
                        "payload": payload_no
                      }
                    ]
                  }
                }
              }
              sendData(messageData1)
              sendData(messageData2)
            
            when "RANDOM" then
            else
              @talk=Fbtalk.find_by(:user => @sender)
              qflowid=@talk.qflowid
              if @payload.include?(qflowid)
                #qflowidが今回のqflowidと一致した場合
                
                #payload配列の取得[qflowid, questionid ,1 or 2]
                payload_array = @payload.split(",")
                
                #answer配列の取得
                @ansarray = @talk.answer.split(",")
                #question配列の取得
                @qarray   = @talk.question.split(",")
                
                @qaHash = Hash.new(0)
                for i in 0..4 do
                  @qaHash[Question.find_by_id(@qarray[i].to_i)]=@ansarray[i]
                end
                
                #既に質問に答えられているかどうか検索
                case @qaHash[Question.find_by_id(payload_array[1].to_i)]
                when "0" then
                  #まだ質問に答えられてない
                  
                  @qaHash[Question.find_by_id(payload_array[1].to_i)] = payload_array[2]
                  
                  if @qaHash.values.include?("0")
                    #答えていない質問がある
                    
                    #答えられていないQuestionオブジェクトの配列
                    notAnsweredQ = @qaHash.select {|k, v| v == "0" }.keys
                    
                    #answerの更新
                    ansData = @qaHash.values.join(",")
                    @talk.update(:answer => ansData)
                    
                    #答えられていない質問のなかで最初のものを送信
                    payload_yes = qflowid+","+notAnsweredQ[0].id.to_s+",1"
                    payload_no  = qflowid+","+notAnsweredQ[0].id.to_s+",2"
                    messageData = {
                      "attachment":{
                        "type":"template",
                        "payload":{
                          "template_type":"button",
                          "text": notAnsweredQ[0].body,
                          "buttons":[
                            {
                              "type":"postback",
                              "title":"はい!",
                              "payload": payload_yes
                            },
                            {
                              "type":"postback",
                              "title":"いいえ!",
                              "payload": payload_no
                            }
                          ]
                        }
                      }
                    }
                    sendData(messageData)
                    
                  else
                    #答えていない質問がない
                    
                    #ベイズ計算&ギフト送信
                    
                    #qflowidの初期化
                    @talk.update(:qflowid =>"")
                    
                    messageData={text: "Thank you!!"}
                    sendData(messageData)
                  end
                when "1","2" then
                  #もう質問に答えている
                  
                  messageData={text: "もう答えてるよ！"}
                  sendData(messageData)
                else
                end
              else
                #qflowidが異なる場合
                messageData = {text: "前回の質問じゃないかな？"}
                sendData(messageData)
              end
            end
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
