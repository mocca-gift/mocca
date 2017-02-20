# for Line Bot 一旦コピペ 20160522

class WebhookController < ApplicationController
  protect_from_forgery with: :null_session # CSRF対策無効化
  
  CHANNEL_SECRET = ENV['CHANNEL_SECRET']
  OUTBOUND_PROXY = ENV['OUTBOUND_PROXY']
  CHANNEL_ACCESS_TOKEN = ENV['CHANNEL_ACCESS_TOKEN']

#   CHANNEL_ID = ENV['LINE_CHANNEL_ID']
#   CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
#   CHANNEL_MID = ENV['LINE_CHANNEL_MID']
# #   OUTBOUND_PROXY = ENV['LINE_OUTBOUND_PROXY']
#   OUTBOUND_PROXY = ENV['FIXIE_URL']

  def callback
    unless is_validate_signature
      render :nothing => true, status: 470
    end
    # result = params[:result][0]
    # logger.info({from_line: result})
    
    #受信したメッセージ
    # text_message = result['content']['text']
    #メッセージ送信者のID
    # replyToken =result['content']['from']
    
    event = params[:events][0]
    event_type = event["type"]
    replyToken = event["replyToken"]
    #受信したメッセージ
    text_message = event['message']['text']
    #メッセージ送信者のID
    userId =event["source"]["userId"]
    
    client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    # client = LineClient.new(CHANNEL_ID, CHANNEL_SECRET, CHANNEL_MID, OUTBOUND_PROXY)
    
    case event_type
    when "message"
      #メッセージ送信者の履歴が過去になければ(質問フローの中にいないなら)
      if Talk.find_by(:user => userId)==nil then
        res = client.reply(replyToken, ["ようこそMOCCAへ\n素敵なプレゼントを\n一緒に探そう！", "どうやって探す？\n\nQ:質問に答えて探す!\nR:運に任せて探す!"])
        # res = client.reply(replyToken, "どうやって探す？\n\nQ:質問に答えて探す!\nR:運に任せて探す!")
        @talk=Talk.create(:user => userId, :text => "")
      else
        
        #前回使用より30分以上経過していたらリセット***************************************************(1)
        if (Time.now - Talk.find_by(:user => userId).updated_at )> 30*60 then
          @talk=Talk.find_by(:user => userId)
          @talk.update(:text => "")
        else
        end
        
        if Talk.find_by(:user => userId).text=="" then
          #メッセージが"Q"なら質問フローを開始する
          case text_message.upcase
          when "Q","Ｑ" then
            #ランダムに質問5個を取ってきてTalkモデルに送信者IDと共に格納
            @questions=Question.order("RANDOM()").limit(5)
            qarray="0"
            @questions.each do |q|
              qarray+=","
              qarray+=q.id.to_s
            end
            # res = client.reply(replyToken, ["プレゼントを渡す相手を想像して...","はい(y)/いいえ(n)で答えてね\nまずは5問！"])
            # res = client.reply(replyToken, "はい(y)/いいえ(n)で答えてね\nまずは5問！")
            # res = client.reply(replyToken, "まずは5問！")
            message=@questions[0].body
            @talk=Talk.find_by(:user => userId)
            @talk.update(:text => "0",:question => qarray)
            res = client.reply(replyToken, ["プレゼントを渡す相手を想像して...","はい(y)/いいえ(n)で答えてね\nまずは5問！", message])
            # res = client.reply(replyToken, message)
          when "R","Ｒ" then
            # res = client.reply(replyToken, "今日の運はどうかな？")
            # res = client.reply(replyToken, "今日の運はこんな感じ！")
            @gift=Gift.offset( rand(Gift.count) ).first
            message=message=@gift.name+"/"+@gift.company_name+"\n"+@gift.url+"\n"
            
            #画像送信とりあえず今は無し
            # res = client.sendImage([replyToken], "https://mocca-giftfinder.herokuapp.com/gifts/"+@gift.id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@gift.id.to_s+"/img" )
            # res = client.reply(replyToken, message)
            
            # message="Web版も試してね！\nhttps://mocca-giftfinder.herokuapp.com/"
            # res = client.reply(replyToken, message)
            res = client.reply(replyToken, ["今日の運はこんな感じ！", message, "もっと探す？\n\nQ:質問に答えて探す!\nR:運に任せて探す!"])
            # res = client.reply(replyToken, "もっと探す？\n\nQ:質問に答えて探す!\nR:運に任せて探す!")
          else
            #"Q""R"以外のメッセージが来た場合
            res = client.reply(replyToken, ["どうやって探す？\n\nQ:質問に答えて探す!\nR:運に任せて探す!"])
          end
          
        else
          #メッセージ送信者の履歴が過去にあれば(質問フローの中にいれば)
          #Talkモデルに格納したデータを取ってくる
          @talk=Talk.find_by(:user => userId)
          @qarray=@talk.question.split(",")
          @ansarray=@talk.text.split(",")
          i=@ansarray.count
          # はいと判断するメッセージ
          yes_array=[/はい！*/, /はい!*/,/うん！*/, /うん!*/,/YES!*/i,/y/i,/1/]
          no_array=[/いいえ！*/, /いいえ!*/,/いーえ!*/,/いや！*/, /いや!*/,/NO!*/i,/n/i,/2/]
          up_array=[/.*いい.*/,/.*最高.*/,/.*さいこー.*/,/.*good.*/i,/.*よい.*/,/.*良.*/,/おっけー！*/,/オッケー！*/,/OK!*/i]
          #答えた質問が5個未満なら
          case i
          when 0,1,2,3,4 then
            case text_message
            when *yes_array then
              message=Question.find_by_id(@qarray[i+1]).body
              @talk.update(:text => @talk.text+",1")
              res = client.reply(replyToken, [message])
            when *no_array then
              message=Question.find_by_id(@qarray[i+1]).body
              @talk.update(:text => @talk.text+",2")
              res = client.reply(replyToken, [message])
            else
              # message="はい/いいえで答えてね"
              # res = client.reply(replyToken, message)
              
              #質問の再表示****************************************************************************(2)
              message=Question.find_by_id(@qarray[i]).body
              res = client.reply(replyToken, ["はい/いいえで答えてね", message])
  # ここでもう一度質問を表示したい
            end
          #答えた質問が5個なら  
          when 5 then
            case text_message
      # ↓YES--------------------------------------------------------------------------
            when *yes_array then
              # res = client.reply(replyToken, "こんなプレゼントはどうかな...")
              # res = client.reply(replyToken, "ちょっと待っててね...")
              @talk.update(:text => @talk.text+",1")
              # ベイズ計算をする。というか@expTop1を生成する
              bayes_calc
              
              #評価初期
              up_calc(@expTop1.id,1)
              down_calc(@expTop1.id,1)
              
              #@expTop1のギフトに関して，その画像,名前(会社名も)，URLと価格帯を送信
              message=@expTop1.name+"/"+@expTop1.company_name+"\n"+@expTop1.url+"\n"
              
              # res = client.sendImage([replyToken], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img" )
              res = client.reply(replyToken, ["ちょっと待っててね...", message, "このプレゼントどうかな？\nいい？ちょっと違う？"])
              
              # message="このプレゼントどうかな？\nいい？ちょっと違う？"
              # message="Web版も試してね！\nhttps://mocca-giftfinder.herokuapp.com/"
              # res = client.reply(replyToken, message)
              #Talkモデルのquestionの最後(6番目)にギフトのidを付加する
              @talk.update(:question => @talk.question+","+@expTop1.id.to_s)
              # message=@expTop1.id.to_s
              # res = client.reply(replyToken, message)
              # @talk.update(:text => "")
      # ↑YES--------------------------------------------------------------------------
      # ↓NO----------------------------------------------------------------------------
            when *no_array then
              # res = client.reply(replyToken, "こんなプレゼントはどうかな...")
              # res = client.reply(replyToken, "ちょっと待っててね...")
              @talk.update(:text => @talk.text+",2")
              # ベイズ計算をする。というか@expTop1を生成する
              bayes_calc
              
              #評価初期
              up_calc(@expTop1.id,1)
              down_calc(@expTop1.id,1)
              
              #@expTop1のギフトに関して，その画像,名前(会社名も)，URLと価格帯を送信
              message=message=@expTop1.name+"/"+@expTop1.company_name+"\n"+@expTop1.url+"\n"
              
              # res = client.sendImage([replyToken], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img" )
              res = client.reply(replyToken, ["ちょっと待っててね...", message,"このプレゼントどうかな？\nいい？ちょっと違う？"] )
              
              # message="このプレゼントどうかな？\nいい？ちょっと違う？"
              # message="Web版もお試し下さい\nhttps://mocca-giftfinder.herokuapp.com/"
              # res = client.reply(replyToken, message)
              #Talkモデルのquestionの最後(6番目)にギフトのidを付加する
              @talk.update(:question => @talk.question+","+@expTop1.id.to_s)
              # message=@expTop1.id.to_s
              # res = client.reply(replyToken, message)
              # @talk.update(:text => "")
            
      # ↑NO----------------------------------------------------------------------------
            else
              message="はい/いいえで答えてね"
              res = client.reply(replyToken, [message])
            end
            
          else
            case text_message
            when *up_array then
            up_calc(@qarray[6],1)
            down_calc(@qarray[6],-1)
            # res = client.reply(replyToken, "ありがとう！\nWeb版も使ってみてね！\nhttps://mocca-giftfinder.herokuapp.com")
            res = client.reply(replyToken, ["ありがとう！\nまた一緒に探そうね！"])
            @talk.update(:text => "")
            # message=@qarray[6].to_s+"up"
            # res = client.reply(replyToken, message)
            else
            up_calc(@qarray[6],-1)
            down_calc(@qarray[6],1)
            # res = client.reply(replyToken, "そっか...またチャレンジしてね！\nWeb版も試してね！\nhttps://mocca-giftfinder.herokuapp.com/")
            res = client.reply(replyToken, ["もう一回やってみて！質問が変わるよ！"])
            @talk.update(:text => "")
            # message=@qarray[6].to_s+"down"
            # res = client.reply(replyToken, message)
            end
          res = client.reply(replyToken, ["どうやって探す？\n\nQ:質問に答えて探す!\nR:運に任せて探す!"])
          end
        end
      end
    end

    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end
    render :nothing => true, status: :ok
  end

  private
  # LINEからのアクセスか確認.
  # 認証に成功すればtrueを返す。
  # ref) https://developers.line.me/bot-api/getting-started-with-bot-api-trial#signature_validation
  def is_validate_signature
    signature = request.headers["X-LINE-ChannelSignature"]
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
    signature_answer = Base64.strict_encode64(hash)
    signature == signature_answer
  end
  
  private
  # ベイズ計算切り出し
  def bayes_calc
          @qarray=@talk.question.split(",")
          @ansarray=@talk.text.split(",")
          
          # answerモデルに結果を代入
        for i in 1..(@ansarray.length-1) do
            answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i]) || Answer.new(question_id: @qarray[i], ansid: @ansarray[i], count: 0)
            answer.save
            answer.update(count: answer.count+1)
        end
        
        #ベイズ
        #ベイズ確率の配列作成
        @bayes=Hash.new(0.5)
      
        @gifts=Gift.all
        
        #ベイズ計算
        for i in 1..5 do
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
        # 一旦1つだけ出力するようにする
        # @expTop3=Array.new(3,Gift.find_by_id(1))
        # for i in 0..(@expTop3.length-1) do
        #     @expTop3[i]=@giftExp.sort_by{|key, value| -value}[i][0]
        # end
        @expTop1=Gift.find_by_id(1)
        @expTop1=@giftExp.sort_by{|key, value| -value}[0][0]
        
        #@expTop3のギフトに関して，その画像と名前，URLを送信する
        # message=message=@expTop3[0].name+"\n"+@expTop3[0].url
        # res = client.sendImage([replyToken], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[0].id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[0].id.to_s+"/img" )
        # res = client.reply(replyToken, message)
        
        # message=message=@expTop3[1].name+"\n"+@expTop3[1].url
        # res = client.sendImage([replyToken], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[1].id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[1].id.to_s+"/img" )
        # res = client.reply(replyToken, message)
        
        # message=message=@expTop3[2].name+"\n"+@expTop3[2].url
        # res = client.sendImage([replyToken], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[2].id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[2].id.to_s+"/img" )
        # res = client.reply(replyToken, message)
        
        # res はただの変数！
        # #@expTop1のギフトに関して，その画像と名前，URLを送信する
        # message=message=@expTop1.name+"\n"+@expTop1.url
        # res = client.sendImage([replyToken], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img" )
        # res = client.reply(replyToken, message)
  end
  
  def up_calc(giftid,num)
    evaluation=Evaluation.where(gift_id: giftid).find_by_evalid(1)
    evaluation.update(count: evaluation.count+num)
    for i in 1..5
      answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i])
      anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation.id)
      anstoeval.update(count: anstoeval.count+num)
    end
  end
  
  def down_calc(giftid,num)
    evaluation=Evaluation.where(gift_id: giftid).find_by_evalid(2)
    evaluation.update(count: evaluation.count+num)
    for i in 1..5
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
        result="Price Unknown"
      end
      
      return result
  end
  
end