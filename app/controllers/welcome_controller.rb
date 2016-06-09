class WelcomeController < ApplicationController
    before_action do
        # 端末によってViewファイルを振り分ける
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
    
    before_action :restrict_remote_ip, only: [:admin]
  
    PERMIT_ADDRESSES = ['127.0.0.1', '::1', '115.165.80.15' ,ENV['MY_IP_ADDRESS'], ENV['MY_SUB_IP_ADDRESS'], ENV['H_IP_ADDRESS']]
    
    def admin
        @giftNum = Gift.count
        @questionNum = Question.count
        @lineNum = Talk.count
        @fbNum = Fbtalk.count
        @useNum = Answer.sum(:count)/5
        render :layout => 'home'
    end
    
    def index
        render :layout => 'home'
    end
    
    def new
        @gifts=Gift.order("created_at DESC").limit(6)
    end
    
    def info
        @infos=Info.order("created_at DESC").limit(3)
    end
    
    private
    
    def restrict_remote_ip
    unless PERMIT_ADDRESSES.include?(request.remote_ip)
      render text: 'Service Unavailable', status: 503
    end
    end
    
end
