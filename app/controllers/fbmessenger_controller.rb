require 'open-uri'
require 'json'


class FbmessengerController < ApplicationController
    protect_from_forgery with: :null_session # CSRF対策無効化
    
    ACCESS_TOKEN = ENV['FB_ACCESS_TOKEN']
    PAGE_ID = ENV['FB_PAGE_ID']
    
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
        
        @messageData_normal={
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
          
          #Welcome Message**********************************************************
          # curl -X POST -H "Content-Type: application/json" -d '{
          #   "setting_type":"call_to_actions",
          #   "thread_state":"new_thread",
          #   "call_to_actions":[
          #     {
          #       "message":{
          #         "attachment":{
          #                 "type":"template",
          #                 "payload":{
          #                   "template_type":"button",
          #                   "text":"ようこそMOCCAへ!\nどうやってギフトを決める?",
          #                   "buttons":[
          #                     {
          #                       "type":"postback",
          #                       "title":"QUESTION",
          #                       "payload":"QUESTION"
          #                     },
          #                     {
          #                       "type":"postback",
          #                       "title":"RANDOM",
          #                       "payload":"RANDOM"
          #                     }
          #                   ]
          #                 }
          #               }
          #       }
          #     }
          #   ]
          # }' "https://graph.facebook.com/v2.6/1623932044594234/thread_settings?access_token=EAAWFQPfGEBkBAEdKXCPOQ5zb28zMOeSKkZAvQjYnODIPOakcDpC92wlHWARJZA4COUu77bBzAhW4SW0ybdPLELIZC8d60EAwoMpv8DBQR1gaHiZA0WZCbhZBxDGXSOIwojLc51OCGHF9EUghwMHy4oZCV55nvU4iZBcxZAZAfEjr3jCCgedb4aZCoSa"
  
          #**************************************************************************
        
        #ユーザの発言かどうかの判定
        if @message.include?("message") then
    
          #ユーザの発言
          
          #ユーザの発言取得
          @text = @message["message"]["text"]
    
          @text="QUESTION:\n質問でギフトを探す!\nRANDOM:\n運に任せてギフトを探す!"
          
          messageData = {text: @text}
        
          sendData(@messageData_normal)
          sendData(messageData)
        
        else
        
          if @message.include?("postback") then
            
            #ユーザからのPOSTBACK
            
            #PAYLOADの取得
            @payload = @message["postback"]["payload"]
            
            case @payload
            when "QUESTION" then
              #ユーザIDでトーク履歴取得(なかったらクリエイト)
              @talk=Fbtalk.find_by(:user => @sender) || Fbtalk.create(:user => @sender, :answer => "", :qflowid => "")
              
              #qflowidとしてタイムスタンプを使用
              qflowid = @message["timestamp"].to_s
              
              #ランダムに質問を5個取得しq_Arrayに格納
              @questions=Question.order("RANDOM()").limit(5)
              q_Array=[0,0,0,0,0]
              i=0
              @questions.each do |q|
                 q_Array[i] = q.id
                 i+=1
              end
              
              #q_Arrayを文字列にして@talkに格納
              qarray=q_Array.join(",")
              
              @talk.update(:answer => "0,0,0,0,0",:question => qarray, :qflowid => qflowid)
              
              #payloadの値の設定
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
              #RANDOMを押された場合
              
              #ランダムでギフトを1つ取得
              @gift=Gift.offset( rand(Gift.count) ).first
              
              messageData1 = {text: "今日の運はどうかな？"}
              messageData2 = {
                "attachment": {
                  "type": "template",
                  "payload": {
                    "template_type": "generic",
                    "elements": [{
                      "title": @gift.name ,
                      "subtitle": @gift.company_name,
                      "image_url": "https://mocca-giftfinder.herokuapp.com/gifts/"+@gift.id.to_s+"/img",
                      "buttons": [{
                        "type": "web_url",
                        "url": @gift.url ,
                        "title": "ご購入はこちらから！"
                      }],
                    }]
                  }
                }
              }
              sendData(messageData1)      
              sendData(messageData2)
              sendData(@messageData_normal)
              
            when /.*eval.*/ then
              #評価された場合
              
              @talk=Fbtalk.find_by(:user => @sender)
              
              #payload[eval,giftid,1 or 2,qflowid]
              payload_array = @payload.split(",")
              
              #qflowidで評価したか否かを判定(一回評価してると初期化される)
              if @talk.qflowid == payload_array[3] then
                
                case payload_array[2]
                when "1" then
                  #評価がLikeの場合
                  up_calc(payload_array[1],1)
                  down_calc(payload_array[1],-1)
                  
                  #qflowid初期化
                  @talk.update( :qflowid => "")
                  
                  messageData={text: "ありがとう!\nまた使ってね!"}
                  sendData(messageData)
                  sendData(@messageData_normal)
                  
                when "2" then
                  #評価がDislikeの場合
                  up_calc(payload_array[1],-1)
                  down_calc(payload_array[1],1)
                  
                  #qflowid初期化
                  @talk.update( :qflowid => "")
                  
                  messageData={text: "また挑戦してね!\n質問が変わるよ!"}
                  sendData(messageData)
                  sendData(@messageData_normal)
                  
                else
              
                end
              else
                #qflowidが異なる場合
                messageData = {text: "評価は一回までだよ!"}
                sendData(messageData)
                sendData(@messageData_normal)
                
              end
              
            else
              @talk=Fbtalk.find_by(:user => @sender)
              qflowid = @talk.qflowid
              #payload配列の取得[qflowid, questionid ,1 or 2]
              payload_array = @payload.split(",")
              
              if payload_array[0]==qflowid then
                #qflowidが今回のqflowidと一致した場合
                
                
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
                  #answerの更新
                  ansData = @qaHash.values.join(",")
                  @talk.update(:answer => ansData)
                  
                  if @qaHash.values.include?("0")
                    #答えていない質問がある
                    
                    #答えられていないQuestionオブジェクトの配列
                    notAnsweredQ = @qaHash.select {|k, v| v == "0" }.keys
                    
                    
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
                    
                    messageData1 = {text: "こんなプレゼントはどうかな？"}
                    sendData(messageData1)
                    
                    bayes_calc
                    
                    #デフォルトで評価を1ずつプラス
                    @expTop3.each do |exp|
                      up_calc(exp.id,1)
                      down_calc(exp.id,1)
                    end
                    
                    messageData = {
                      "attachment": {
                        "type": "template",
                        "payload": {
                          "template_type": "generic",
                          "elements": [{
                            "title": @expTop3[2].name ,
                            "subtitle": @expTop3[2].company_name,
                            # "image_url": "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[2].id.to_s+"/img",
                            "buttons": [{
                              "type": "web_url",
                              "url": @expTop3[2].url ,
                              "title": "ご購入はこちらから！"
                            }, {
                              "type": "postback",
                              "title": "👍Like",
                              "payload": "eval,"+@expTop3[2].id.to_s+",1,"+qflowid,
                            }, {
                              "type": "postback",
                              "title": "👎Dislike",
                              "payload": "eval,"+@expTop3[2].id.to_s+",2,"+qflowid,
                            }],
                          },{
                            "title": @expTop3[1].name ,
                            "subtitle": @expTop3[1].company_name,
                            # "image_url": "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[1].id.to_s+"/img",
                            "buttons": [{
                              "type": "web_url",
                              "url": @expTop3[1].url ,
                              "title": "ご購入はこちらから！"
                            }, {
                              "type": "postback",
                              "title": "👍Like",
                              "payload": "eval,"+@expTop3[1].id.to_s+",1,"+qflowid,
                            }, {
                              "type": "postback",
                              "title": "👎Dislike",
                              "payload": "eval,"+@expTop3[1].id.to_s+",2,"+qflowid,
                            }],
                          },{
                            "title": @expTop3[0].name ,
                            "subtitle": @expTop3[0].company_name,
                            # "image_url": "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[0].id.to_s+"/img",
                            "buttons": [{
                              "type": "web_url",
                              "url": @expTop3[0].url ,
                              "title": "ご購入はこちらから！"
                            }, {
                              "type": "postback",
                              "title": "(👍Like",
                              "payload": "eval,"+@expTop3[0].id.to_s+",1,"+qflowid,
                            }, {
                              "type": "postback",
                              "title": "👎Dislike",
                              "payload": "eval,"+@expTop3[0].id.to_s+",2,"+qflowid,
                            }],
                          }]
                        }
                      }
                    }
                    
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
                sendData(@messageData_normal)
                
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
    
    #ベイズ計算関数
    def bayes_calc
            @qarray=@talk.question.split(",")
            @ansarray=@talk.answer.split(",")
            
            # answerモデルに結果を代入
          for i in 0..4 do
              answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i]) || Answer.new(question_id: @qarray[i], ansid: @ansarray[i], count: 0)
              answer.save
              answer.update(count: answer.count+1)
          end
          
          #ベイズ
          #ベイズ確率の配列作成
          @bayes=Hash.new(0.5)
        
          @gifts=Gift.all
          
          #ベイズ計算
          for i in 0..4 do
            @gifts.each do |gift|
              answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i])
              evaluation1=Evaluation.where(gift_id: gift.id).find_by_evalid(1) || Evaluation.new(gift_id: gift.id, evalid: 1, count: 0)
              evaluation1.save
              evaluation2=Evaluation.where(gift_id: gift.id).find_by_evalid(2) || Evaluation.new(gift_id: gift.id, evalid: 2, count: 0)
              evaluation2.save
              anstoeval1=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation1.id) || Anstoeval.new(answer_id: answer.id, evaluation_id: evaluation1.id, count: 1)
              anstoeval1.save
              anstoeval2=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation2.id) || Anstoeval.new(answer_id: answer.id, evaluation_id: evaluation2.id, count: 1)
              anstoeval2.save
              p1=1.0*anstoeval1.count/(anstoeval1.count + anstoeval2.count)
              @bayes[gift] = @bayes[gift]*p1/(@bayes[gift]*p1+(1-@bayes[gift])*(1-p1))
            end
          end
          
          #期待値の配列作成
          
          @giftExp     = Hash.new(1.0/2.0)
          
          #期待値と分散値の配列に値を代入
          
          @gifts.each do |gift|
              # gift毎に[giftオブジェクト,期待値(Bayes更新あり)]のhash作成
              @giftExp[gift] = 1-2*@bayes[gift]
          end

          # @expTop1=Gift.find_by_id(1)
          # @expTop1=@giftExp.sort_by{|key, value| -value}[0][0]
          
          #価格帯でギフトを分類
          @giftExp1 = @giftExp.select {|k, v| k.price==1}
          @giftExp2 = @giftExp.select {|k, v| k.price==2}
          @giftExp3 = @giftExp.select {|k, v| k.price==3}
          @giftExp4 = @giftExp.select {|k, v| k.price==4}
          @giftExp5 = @giftExp.select {|k, v| k.price==5}
          
          @giftExp12 = @giftExp1.merge(@giftExp2)
          @giftExp45 = @giftExp4.merge(@giftExp5)
          
          @expTop3=Array.new(3,Gift.find_by_id(1))
            @expTop3[0]=@giftExp45.sort_by{|key, value| -value}[0][0]
            @expTop3[1]=@giftExp3.sort_by{|key, value| -value}[0][0]
            @expTop3[2]=@giftExp12.sort_by{|key, value| -value}[0][0]

          
    end
  
    def up_calc(giftid,num)
      @qarray=@talk.question.split(",")
      @ansarray=@talk.answer.split(",")
      evaluation=Evaluation.where(gift_id: giftid ).find_by_evalid(1)
      evaluation.update(count: evaluation.count+num)
      for i in 0..4
        answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i])
        anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation.id)
        anstoeval.update(count: anstoeval.count+num)
      end
    end
    
    def down_calc(giftid,num)
      @qarray=@talk.question.split(",")
      @ansarray=@talk.answer.split(",")
      evaluation=Evaluation.where(gift_id: giftid ).find_by_evalid(2)
      evaluation.update(count: evaluation.count+num)
      for i in 0..4
        answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i])
        anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation.id)
        anstoeval.update(count: anstoeval.count+num)
      end
    end
    
    def priceView(num)
      case num
      when 1 then
        result="$"
      when 2 then
        result="$$"
      when 3 then
        result="$$$"
      when 4 then
        result="$$$$"
      when 5 then
        result="$$$$$"
      else
        result=""
      end
      
      return result
    end

end
