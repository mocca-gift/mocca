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
    
    if Talk.find_by(:user => from_mid)==nil then
      case text_message.upcase
      when "Q" then
        @question=Question.order("RANDOM()").limit(1)
        message=@question.body+"\n YESの場合は1をNOの場合は2を返して下さい．"
        @talk=Talk.create(:user => from_mid, :text => text_message)
      else
        message="質問を始めたい時はQと送って下さい．"
      end
      
    else
      if Talk.where(:user => from_mid).count<5 then
        case text_message
        when "1" then
          @question=Question.offset( rand(Question.count) ).first
          message=@question.body+"\n YESの場合は1をNOの場合は2を返して下さい．"
          @talk=Talk.create(:user => from_mid, :text => text_message)
        when "2" then
          @question=Question.offset( rand(Question.count) ).first
          message=@question.body+"\n YESの場合は1をNOの場合は2を返して下さい．"
          @talk=Talk.create(:user => from_mid, :text => text_message)
        else
          message="1か2で答えてください"
        end
      else
        message="Result should come"
        Talk.destroy_all(:user => from_mid)
      end
    end
    
    client = LineClient.new(CHANNEL_ID, CHANNEL_SECRET, CHANNEL_MID, OUTBOUND_PROXY)
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