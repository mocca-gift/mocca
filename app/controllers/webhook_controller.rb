# for Line Bot 一旦コピペ 20160522

class WebhookController < ApplicationController
  protect_from_forgery with: :null_session # CSRF対策無効化

  CHANNEL_ID = ENV['LINE_CHANNEL_ID']
  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  CHANNEL_MID = ENV['LINE_CHANNEL_MID']
#   OUTBOUND_PROXY = ENV['LINE_OUTBOUND_PROXY']
  OUTBOUND_PROXY = ENV['FIXIE_URL']

  def callback
    unless is_validate_signature
      render :nothing => true, status: 470
    end
    result = params[:result][0]
    logger.info({from_line: result})
    
    #受信したメッセージ
    text_message = result['content']['text']
    #メッセージ送信者のID
    from_mid =result['content']['from']
    
    client = LineClient.new(CHANNEL_ID, CHANNEL_SECRET, CHANNEL_MID, OUTBOUND_PROXY)
    
    
    #メッセージ送信者の履歴が過去になければ(質問フローの中にいないなら)
    if Talk.find_by(:user => from_mid)==nil then
      res = client.send([from_mid], "ようこそMOCCAへ\n素敵なプレゼントを\n一緒に探してみませんか")
      res = client.send([from_mid], "Q:質問に答えて探す!\nR:運に任せて探す!")
      @talk=Talk.create(:user => from_mid, :text => "")
    else
      if Talk.find_by(:user => from_mid).text=="" then
        #メッセージが"Q"なら質問フローを開始する
        case text_message.upcase
        when "Q" then
          #ランダムに質問5個を取ってきてTalkモデルに送信者IDと共に格納
          @questions=Question.order("RANDOM()").limit(5)
          qarray="0"
          @questions.each do |q|
            qarray+=","
            qarray+=q.id.to_s
          end
          res = client.send([from_mid], "プレゼントを渡す相手を想像して...")
          res = client.send([from_mid], "「はい/いいえ」で答えてね")
          res = client.send([from_mid], "まずは5問！")
          message=@questions[0].body
          @talk=Talk.find_by(:user => from_mid)
          @talk.update(:text => "0",:question => qarray)
          res = client.send([from_mid], message)
        when "R" then
          res = client.send([from_mid], "今日の運はどうでしょう？")
          @gift=Gift.offset( rand(Gift.count) ).first
          message=message=@gift.name+"\n"+@gift.url
          res = client.sendImage([from_mid], "https://mocca-giftfinder.herokuapp.com/gifts/"+@gift.id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@gift.id.to_s+"/img" )
          res = client.send([from_mid], message)
          
          message="Web版も試してね！\nhttps://mocca-giftfinder.herokuapp.com/"
          res = client.send([from_mid], message)
        else
          #"Q""R"以外のメッセージが来た場合
          res = client.send([from_mid], "Q:質問に答えて探す!\nR:運に任せて探す!")
        end
        
      else
        #メッセージ送信者の履歴が過去にあれば(質問フローの中にいれば)
        #Talkモデルに格納したデータを取ってくる
        @talk=Talk.find_by(:user => from_mid)
        @qarray=@talk.question.split(",")
        @ansarray=@talk.text.split(",")
        i=@ansarray.count
        # はいと判断するメッセージ
        yes_array=[/はい！*/, /はい!*/,/うん！*/, /うん!*/,/YES!*/i,/y/i,/1/]
        no_array=[/いいえ！*/, /いいえ!*/,/いーえ!*/,/いや！*/, /いや!*/,/NO!*/i,/n/i,/2/]
        up_array=[/.*いい.*/,/.*最高.*/,/.*さいこー.*/]
        #答えた質問が5個未満なら
        case i
        when 0,1,2,3,4 then
          case text_message
          when *yes_array then
            message=Question.find_by_id(@qarray[i+1]).body
            @talk.update(:text => @talk.text+",1")
            res = client.send([from_mid], message)
          when *no_array then
            message=Question.find_by_id(@qarray[i+1]).body
            @talk.update(:text => @talk.text+",2")
            res = client.send([from_mid], message)
          else
            message="「はい/いいえ」で答えてね"
            res = client.send([from_mid], message)
          end
          
        when 5 then
          case text_message
    # ↓YES--------------------------------------------------------------------------
          when *yes_array then
            res = client.send([from_mid], "こんなプレゼントはどうかな...")
            @talk.update(:text => @talk.text+",1")
            bayes_calc
            #@expTop1のギフトに関して，その画像と名前，URLを送信する
            message=message=@expTop1.name+"\n"+@expTop1.url
            res = client.sendImage([from_mid], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img" )
            res = client.send([from_mid], message)
            
            message="このプレゼントどう？"
            # message="Web版も試してね！\nhttps://mocca-giftfinder.herokuapp.com/"
            res = client.send([from_mid], message)
            
            @talk.update(:question => @talk.question+","+@expTop1.id.to_s)
            message=@expTop1.id.to_s
            res = client.send([from_mid], message)
            # @talk.update(:text => "")
    # ↑YES--------------------------------------------------------------------------
    # ↓NO----------------------------------------------------------------------------
          when *no_array then
            res = client.send([from_mid], "こんなプレゼントはどうかな...")
            @talk.update(:text => @talk.text+",2")
            # ん？これで呼べてるの？
            bayes_calc
            #@expTop1のギフトに関して，その画像と名前，URLを送信する
            message=message=@expTop1.name+"\n"+@expTop1.url
            res = client.sendImage([from_mid], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img" )
            res = client.send([from_mid], message)
            
            message="このプレゼントどう？"
            # message="Web版もお試し下さい\nhttps://mocca-giftfinder.herokuapp.com/"
            res = client.send([from_mid], message)
            
            @talk.update(:question => @talk.question+","+@expTop1.id.to_s)
            message=@expTop1.id.to_s
            res = client.send([from_mid], message)
            # @talk.update(:text => "")
          
    # ↑NO----------------------------------------------------------------------------
          else
            message="「はい/いいえ」で答えてね"
            res = client.send([from_mid], message)
          end
          
        else
          case text_message
          when *up_array then
          up_calc
          res = client.send([from_mid], "ありがとう！\nWeb版も試してね！\nhttps://mocca-giftfinder.herokuapp.com/")
          @talk.update(:text => "")
          message=@qarray[6].to_s+"up"
          res = client.send([from_mid], message)
          else
          down_calc
          res = client.send([from_mid], "そっか...またチャレンジしてね！\nWeb版も試してね！\nhttps://mocca-giftfinder.herokuapp.com/")
          message=@qarray[6].to_s+"down"
          @talk.update(:text => "")
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
        # res = client.sendImage([from_mid], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[0].id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[0].id.to_s+"/img" )
        # res = client.send([from_mid], message)
        
        # message=message=@expTop3[1].name+"\n"+@expTop3[1].url
        # res = client.sendImage([from_mid], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[1].id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[1].id.to_s+"/img" )
        # res = client.send([from_mid], message)
        
        # message=message=@expTop3[2].name+"\n"+@expTop3[2].url
        # res = client.sendImage([from_mid], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[2].id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop3[2].id.to_s+"/img" )
        # res = client.send([from_mid], message)
        
        # res はただの変数！
        # #@expTop1のギフトに関して，その画像と名前，URLを送信する
        # message=message=@expTop1.name+"\n"+@expTop1.url
        # res = client.sendImage([from_mid], "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img", "https://mocca-giftfinder.herokuapp.com/gifts/"+@expTop1.id.to_s+"/img" )
        # res = client.send([from_mid], message)
  end
  
  def up_calc
    for i in 1..5
      answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i])
      evaluation=Evaluation.where(gift_id: @qarray[6]).find_by_evalid(1)
      anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation.id)
      anstoeval.update(count: anstoeval.count+1)
    end
  end
  
  def down_calc
    for i in 1..5
      answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i])
      evaluation=Evaluation.where(gift_id: @qarray[6]).find_by_evalid(2)
      anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation.id)
      anstoeval.update(count: anstoeval.count+1)
    end
  end
  
  
end