# 結果画面を制御するクラス
# 1.回答を取得
# 2.回答から推定を行う
# 3.推定結果で結果（商品）を取得
# 4.結果のviewを呼ぶ
class ResultController < ApplicationController
    def index
        @ansarray=params[:postdata1]
        @qarray=params[:postdata2]
        # answerモデルに結果を代入
        for i in 0..4 do
            @answer=Answer.where(question_id: @qarray[2*i]).find_by_ansid(@ansarray[2*i]) || Answer.new(question_id: @qarray[2*i], ansid: @ansarray[2*i], count: 0)
            @answer.save
            n=@answer.count
            @answer.update(count: n+1)
        end
        @answers=Answer.order("question_id, ansid")
        #ベイズ
        @bayes=[]
        @expectation=[]
        @dispersion=[]
        @maxE=-1
        @maxV=0
        @intE=1
        @intV=1
        #ベイズ確率初期化
        @num=Gift.count
        for i in 1..@num do
            @bayes[i]=1.0/2.0
        end
        #ベイズ計算
        for i in 0..4 do
          for j in 1..@num do
            @answer=Answer.where(question_id: @qarray[2*i]).find_by_ansid(@ansarray[2*i])
            @evaluation1=Evaluation.where(gift_id: j).find_by_evalid(1) || Evaluation.new(gift_id: j, evalid: 1, count: 0)
            @evaluation1.save
            @evaluation2=Evaluation.where(gift_id: j).find_by_evalid(2) || Evaluation.new(gift_id: j, evalid: 2, count: 0)
            @evaluation2.save
            @anstoeval1=Anstoeval.where(answer_id: @answer.id).find_by_evaluation_id(@evaluation1.id) || Anstoeval.new(answer_id: @answer.id, evaluation_id: @evaluation1.id, count: 0)
            @anstoeval1.save
            @anstoeval2=Anstoeval.where(answer_id: @answer.id).find_by_evaluation_id(@evaluation2.id) || Anstoeval.new(answer_id: @answer.id, evaluation_id: @evaluation2.id, count: 0)
            @anstoeval2.save
            if (@anstoeval1.count==0 && @anstoeval2.count==0) then
                p1=0.5
            else
                p1=1.0*@anstoeval1.count/(@anstoeval1.count+@anstoeval2.count)
            end
            @bayes[j]=@bayes[j]*p1/(@bayes[j]*p1+(1-@bayes[j])*(1-p1))
          end
        end
        #期待値の計算
        for i in 1..@num do
            @expectation[i]=1-2*@bayes[i]
        end
        #分散値の計算
        for i in 1..@num do
            @dispersion[i]=@bayes[i]*(-1-@expectation[i])**2+(1-@bayes[i])*(1-@expectation[i])**2
        end
        #期待値が最も高いギフトのID
        for i in 1..@num do
         if @maxE < @expectation[i] then
             @maxE=@expectation[i]
             @intE=i
         else
         end
        end
        #分散値が最も高いギフトのID
        for i in 1..@num do
         if @maxV < @dispersion[i] then
             @maxV=@dispersion[i]
             @intV=i
         else
         end
        end
        @anstoevals=Anstoeval.all
        #ギフトデータの取得
        @gift1=Gift.find_by_id(@intE)
        @gift2=Gift.find_by_id(@intV)
    end
    
    # TODO: ユーザーの回答を取得する
    # TODO: 回答から推定を行う（期待値が最高）
    # TODO: 回答から推定を行う（分散値が最高）
    # TODO: 推定結果から商品を検索
    
    def countup
        gid=params[:gift]
        gans=params[:gift_ans]
        gq=params[:gift_q]
        @res=[]
        @evaluation=Evaluation.where(gift_id: gid).find_by_evalid(2)
        for i in 0..4
          @answer=Answer.where(question_id: gq[2*i]).find_by_ansid(gans[2*i])
          @anstoeval=Anstoeval.where(answer_id: @answer.id).find_by_evaluation_id(@evaluation)
          n=@anstoeval.count
          @anstoeval.update(count: n+1)
          @res[i]=@anstoeval
        end
        @msg="Succeed up!"
        
    end
    
    def countdown
        gid=params[:gift]
        gans=params[:gift_ans]
        gq=params[:gift_q]
        @res=[]
        @evaluation=Evaluation.where(gift_id: gid).find_by_evalid(1)
        for i in 0..4
          @answer=Answer.where(question_id: gq[2*i]).find_by_ansid(gans[2*i])
          @anstoeval=Anstoeval.where(answer_id: @answer.id).find_by_evaluation_id(@evaluation)
          n=@anstoeval.count
          @anstoeval.update(count: n+1)
          @res[i]=@anstoeval
        end
        @msg="Succeed down!"
    end
end
