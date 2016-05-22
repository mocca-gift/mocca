class WelcomeController < ApplicationController
    before_action do
        # 動作確認しやすくするために params[:device] の値で分岐する.
        # 通常は request.user_agent など値で判定する.
        case params[:device]
          when 'tablet'
            request.variant = :tablet
          when 'mobile'
            request.variant = :mobile
        end
    end
    
    def index
    end
    
    def new
        @gifts=Gift.order("created_at DESC").limit(6)
    end
    
    def info
    end
    
end
