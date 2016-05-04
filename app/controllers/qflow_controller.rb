# 質問のフローを制御するクラス
  # 1.質問をDBから取得
  # 2.質問の型を変換
  # 3.Questionのviewを呼ぶ
class QflowController < ApplicationController
    def index
        @questions=Question.order("RANDOM()").limit(5)
    end
end
