class WelcomeController < ApplicationController
    
    def index
    end
    
    def new
        @gifts=Gift.order("created_at DESC").limit(6)
    end
    
    def info
    end
    
end
