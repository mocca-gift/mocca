# 結果画面を制御するクラス
# 1.回答を取得
# 2.回答から推定を行う
# 3.推定結果で結果（商品）を取得
# 4.結果のviewを呼ぶ
class ResultController < ApplicationController
    before_action do
        #端末によってViewファイルを振り分ける
        if (request.user_agent.include?("Mobile") || request.user_agent.include?("iPhone")) || request.user_agent.include?("Android") then
            request.variant = :mobile
        else
        end
        # case params[:device]
        # when 'tablet'
        #   request.variant = :tablet
        # when 'mobile'
        #   request.variant = :mobile
        # end
    end
    
    def index
        @ansarray=params[:postdata1].split(",")
        @qarray=params[:postdata2].split(",")
        
        # answerモデルに結果を代入
        # for i in 0..4 do
        for i in 0..(@ansarray.length-1) do
            answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i]) || Answer.new(question_id: @qarray[i], ansid: @ansarray[i], count: 0)
            answer.save
            #n=answer.count
            answer.update(count: answer.count+1)
        end
        
        
        #ベイズ
        #ベイズ確率の配列作成
        if session[:bayes]
            @bayes=decode_session(session[:bayes])
        else
        @bayes=Hash.new(0.5)
        end
        
        #ベイズ確率の新しい配列作成
        @bayes_new=Hash.new(0.5)
        
        #hGift[gift,0 or 1]
        if session[:gifts]
            @hGifts=decode_session(session[:gifts])
        else
        @hGifts=Hash.new(0)
        end

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
            @bayes_new[gift] = @bayes_new[gift]*p1/(@bayes_new[gift]*p1+(1-@bayes_new[gift])*(1-p1))
          end
        end
        
        #期待値の配列作成
        
        @giftExp     = Hash.new(1.0/2.0)
        @giftExp_new = Hash.new(1.0/2.0)
        
        #期待値と分散値の配列に値を代入
        
        @gifts.each do |gift|
            # gift毎に[giftオブジェクト,期待値(Bayes更新あり)]のhash作成
            @giftExp[gift] = 1-2*@bayes[gift]
            # gift毎に[giftオブジェクト,期待値(Bayes更新なし)]のhash作成
            @giftExp_new[gift] = 1-2*@bayes_new[gift]
        end
        
        
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

        @giftExp_new.except!(@expTop3[0],@expTop3[1],@expTop3[2])
        
        @giftExp1_new = @giftExp_new.select {|k, v| k.price==1}
        @giftExp2_new = @giftExp_new.select {|k, v| k.price==2}
        @giftExp3_new = @giftExp_new.select {|k, v| k.price==3}
        @giftExp4_new = @giftExp_new.select {|k, v| k.price==4}
        @giftExp5_new = @giftExp_new.select {|k, v| k.price==5}
        
        @giftExp12_new = @giftExp1_new.merge(@giftExp2_new)
        @giftExp45_new = @giftExp4_new.merge(@giftExp5_new)

        #Bayes更新なしの期待値上位3件取得
        @expTop3_new = Array.new(3,Gift.find_by_id(1))
        #   @expTop3_new[0]=@giftExp45_new.sort_by{|key, value| -value}[0][0]
        #   @expTop3_new[1]=@giftExp3_new.sort_by{|key, value| -value}[0][0]
        #   @expTop3_new[2]=@giftExp12_new.sort_by{|key, value| -value}[0][0]
        @expTop3_new[0]=@giftExp45_new.sort_by{rand}[0][0]
        @expTop3_new[1]=@giftExp3_new.sort_by{rand}[0][0]
        @expTop3_new[2]=@giftExp12_new.sort_by{rand}[0][0]
        
        #Bayes更新ありとなしを結合
        @giftRes=Array.new()
        @giftRes[0]=@expTop3[0]
        @giftRes[1]=@expTop3_new[0]
        @giftRes[2]=@expTop3[1]
        @giftRes[3]=@expTop3_new[1]
        @giftRes[4]=@expTop3[2]
        @giftRes[5]=@expTop3_new[2]
        
        #デフォルトでgiftの評価は1(bad)にする
            
        @giftRes.each do |gift|
            @evaluation1=Evaluation.where(gift_id: gift.id).find_by_evalid(1)
            @evaluation2=Evaluation.where(gift_id: gift.id).find_by_evalid(2)
            @evaluation1.update(count: @evaluation1.count+1)
            @evaluation2.update(count: @evaluation2.count+1)
            for i in 0..(@ansarray.length-1) do
                answer=Answer.where(question_id: @qarray[i]).find_by_ansid(@ansarray[i])
                e1up(answer)
                e2up(answer)
            end
        end
        
        #*********************************************************************
        # 一度評価がbadだったら再表示しない
        # @gifts.each do |gift|
        #     if @expTop3.include?(gift) || @dispTop3.include?(gift)
        #         @hGifts[gift]=1
        #     else
        #     end
        # end
        #********************************************************************
        
        # sessionの保管
        session[:gifts]=code_session(@hGifts)
        session[:bayes]=code_session(@bayes)
        
        #残りの質問数が5問未満になったらContinue出来なくなる
        @continue_display=0
        @hQuestions=session[:questions]
        if @hQuestions.select {|k, v| v == 0 }.size < 5 then
            @continue_display=1
        else
        end
        
    end
    
    
    def countup
        gid=params[:gift]
        gans=params[:gift_ans].split(",")
        gq=params[:gift_q].split(",")
        hGifts=decode_session(session[:gifts])
        hGifts[Gift.find(gid)]=2
        
        @evaluation1=Evaluation.where(gift_id: gid).find_by_evalid(1)
        @evaluation2=Evaluation.where(gift_id: gid).find_by_evalid(2)
        @evaluation1.update(count: @evaluation1.count-1)
        @evaluation2.update(count: @evaluation2.count+1)
        
        for i in 0..4
          answer=Answer.where(question_id: gq[i]).find_by_ansid(gans[i])
          
          e1down(answer)
          e2up(answer)
        end
         session[:gifts]=code_session(hGifts)
        
        render text: "Succeedup! Gift"+gid
        
    end
    
    def countdown
        gid=params[:gift]
        gans=params[:gift_ans].split(",")
        gq=params[:gift_q].split(",")
        hGifts=decode_session(session[:gifts])
        hGifts[Gift.find(gid)]=1
        
        @evaluation1=Evaluation.where(gift_id: gid).find_by_evalid(1)
        @evaluation2=Evaluation.where(gift_id: gid).find_by_evalid(2)
        @evaluation1.update(count: @evaluation1.count+1)
        @evaluation2.update(count: @evaluation2.count-1)
        
        for i in 0..4
          answer=Answer.where(question_id: gq[i]).find_by_ansid(gans[i])
          e2down(answer)
          e1up(answer)
        end
        session[:gifts]=code_session(hGifts)
        render text: "Succeeddown! Gift"+gid
    end
    
    def countdown2
        gid=params[:gift]
        gans=params[:gift_ans].split(",")
        gq=params[:gift_q].split(",")
        hGifts=decode_session(session[:gifts])
        hGifts[Gift.find(gid)]=1
        
        @evaluation1=Evaluation.where(gift_id: gid).find_by_evalid(1)
        @evaluation2=Evaluation.where(gift_id: gid).find_by_evalid(2)
        @evaluation1.update(count: @evaluation1.count+2)
        @evaluation2.update(count: @evaluation2.count-2)
        
        for i in 0..4
          answer=Answer.where(question_id: gq[i]).find_by_ansid(gans[i])
          e2downdouble(answer)
          e1updouble(answer)
        end
        session[:gifts]=code_session(hGifts)
        render text: "Succeeddown! Gift"+gid
    end
    
    private
        def e2up(answer)
            # evaluation=Evaluation.where(gift_id: gift.id).find_by_evalid(2)
            anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(@evaluation2.id)
            anstoeval.update(count: anstoeval.count+1)
        end
        def e2down(answer)
            # evaluation=Evaluation.where(gift_id: gift.id).find_by_evalid(2)
            anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(@evaluation2.id)
            anstoeval.update(count: anstoeval.count-1)
        end
        def e2downdouble(answer)
            # evaluation=Evaluation.where(gift_id: gift.id).find_by_evalid(2)
            anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(@evaluation2.id)
            anstoeval.update(count: anstoeval.count-2)
        end
        
        def e1up(answer)
            # evaluation=Evaluation.where(gift_id: gift.id).find_by_evalid(1)
            anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(@evaluation1.id)
            anstoeval.update(count: anstoeval.count+1)
        end
        def e1updouble(answer)
            # evaluation=Evaluation.where(gift_id: gift.id).find_by_evalid(1)
            anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(@evaluation1.id)
            anstoeval.update(count: anstoeval.count+2)
        end
        def e1down(answer)
            # evaluation=Evaluation.where(gift_id: gift.id).find_by_evalid(1)
            anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(@evaluation1.id)
            anstoeval.update(count: anstoeval.count-1)
        end
    
        def code_session(hash)
            nhash=Hash.new
            hash.each_key do |key|
                nhash[key.id]=hash[key]
            end
            return nhash
        end
        def decode_session(hash)
            nhash=Hash.new
            hash.each_key do |key|
                nhash[Gift.find(key)]=hash[key]
            end
            return nhash
        end
end
