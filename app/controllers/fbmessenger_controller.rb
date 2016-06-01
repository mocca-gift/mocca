class FbmessengerController < ApplicationController
    def callback
        if params["hub.verify_token"] == "EAAWFQPfGEBkBAE71fCNh9vLkhPQF3pvDVsEgC0ak92iyYH9E9Vnin2UyEK8D3s5GqoZAFvkrZAe8pkg82SViLFB9J9ckqQBnGciInHXhqJcwfs0jLA3AF5ZAPRR7Jo9XNNKzKJcawXBlz8r9Bt2ZC8sZA6G0kLx9B1dDeNTS93wzf3LwUmFka"
           render json: params["hub.challenge"]
        else
           render json: "Error, wrong validation token"
        end
    end

end
