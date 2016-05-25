class WelcomeController < ApplicationController
    before_action do
        #端末によってViewファイルを振り分ける
        case request.user_agent
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
