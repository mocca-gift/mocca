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
    
    text_message = result['content']['text']
    from_mid =result['content']['from']
    
    client = LineClient.new(CHANNEL_ID, CHANNEL_SECRET, CHANNEL_MID, OUTBOUND_PROXY)
    
    if Talk.find_by(:user => from_mid)==nil then
      case text_message.upcase
      when "Q" then
        @questions=Question.order("RANDOM()").limit(5)
        qarray="0"
        @questions.each do |q|
          qarray+=","
          qarray+=q.id.to_s
        end
        res = client.send([from_mid], "「はい」か「いいえ」で答えてください")
        message=@questions[0].body
        @talk=Talk.create(:user => from_mid, :text => "0", :question => qarray)
      else
        message="質問を始めたい時はQと送って下さい．"
      end
      
    else
      @talk=Talk.find_by(:user => from_mid)
      @qarray=@talk.question.split(",")
      @ansarray=@talk.text.split(",")
      i=@ansarray.count
      if i<5 then
        case text_message
        when "はい" then
          message=Question.find_by_id(@qarray[i+1]).body
          @talk.update(:text => @talk.text+",1")
        when "いいえ" then
          message=Question.find_by_id(@qarray[i+1]).body
          @talk.update(:text => @talk.text+",2")
        else
          message="「はい」か「いいえ」で答えてください"
        end
      else
        res = client.send([from_mid], "あなたに最適なギフトは...")
        @talk.update(:text => @talk.text+","+text_message)
        
        # answerモデルに結果を代入
        # for i in 0..4 do
        for i in 1..(@ansarray.length) do
            answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i]) || Answer.new(question_id: @qarray[i], ansid: @ansarray[i], count: 0)
            answer.save
            #n=answer.count
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
        
        @expTop3=Array.new(3,Gift.find_by_id(1))
        for i in 0..(@expTop3.length-1) do
            @expTop3[i]=@giftExp.sort_by{|key, value| -value}[i][0]
        end
        message=message=@expTop3[0].name+"\n"+@expTop3[0].url
        res = client.send([from_mid], message)
        res = client.sendImage([from_mid], "https://guarded-reaches-70446.herokuapp.com/gifts/"+@expTop3[0].id.to_s+"/img", "https://guarded-reaches-70446.herokuapp.com/gifts/"+@expTop3[0].id.to_s+"/img" )
        message=message=@expTop3[1].name+"\n"+@expTop3[1].url
        res = client.send([from_mid], message)
        res = client.sendImage([from_mid], "https://guarded-reaches-70446.herokuapp.com/gifts/"+@expTop3[1].id.to_s+"/img", "https://guarded-reaches-70446.herokuapp.com/gifts/"+@expTop3[1].id.to_s+"/img" )
        message=message=@expTop3[2].name+"\n"+@expTop3[2].url
        res = client.send([from_mid], message)
        res = client.sendImage([from_mid], "https://guarded-reaches-70446.herokuapp.com/gifts/"+@expTop3[2].id.to_s+"/img", "https://guarded-reaches-70446.herokuapp.com/gifts/"+@expTop3[2].id.to_s+"/img" )
        message="気に入りましたか？"
        Talk.destroy_all(:user => from_mid)
      end
    end
    
    res = client.send([from_mid], message)

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
end