class GiftsController < ApplicationController
  before_action :set_gift, only: [:show, :edit, :update, :destroy, :img]
  before_action :restrict_remote_ip


  # GET /gifts
  # GET /gifts.json
  def index
    @gifts = Gift.all
  end

  # GET /gifts/1
  # GET /gifts/1.json
  def show
  end

  # GET /gifts/new
  def new
    @gift = Gift.new
  end

  # GET /gifts/1/edit
  def edit
  end

  # POST /gifts
  # POST /gifts.json
  def create
    @gift = Gift.new(gift_params)
    #画像が登録されていなかったらid１の画像を設定する
    if params[:gift][:img] !=nil
      @gift.img = params[:gift][:img].read # <= バイナリをセット
      @gift.img_content_type = params[:gift][:img].content_type # <= ファイルタイプをセット
    else
      @gift.img = Gift.find(1).img
      @gift.img_content_type = Gift.find(1).img_content_type
    end

    respond_to do |format|
      if @gift.save
        format.html { redirect_to @gift, notice: 'Gift was successfully created.' }
        format.json { render :show, status: :created, location: @gift }
      else
        format.html { render :new }
        format.json { render json: @gift.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gifts/1
  # PATCH/PUT /gifts/1.json
  def update
    respond_to do |format|
      if @gift.update(gift_params)
        if params[:gift][:img] !=nil
          @gift.update(:img => params[:gift][:img].read) # <= バイナリをセット
          @gift.update(:img_content_type => params[:gift][:img].content_type) # <= ファイルタイプをセット
        else
          @gift.update(:img => Gift.find(1).img) # <= バイナリをセット
          @gift.update(:img_content_type => Gift.find(1).img_content_type) # <= ファイルタイプをセット
        end
        format.html { redirect_to @gift, notice: 'Gift was successfully updated.' }
        format.json { render :show, status: :ok, location: @gift }
      else
        format.html { render :edit }
        format.json { render json: @gift.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gifts/1
  # DELETE /gifts/1.json
  def destroy
    @gift.destroy
    respond_to do |format|
      format.html { redirect_to gifts_url, notice: 'Gift was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def img
  send_data(@gift.img, type: @gift.img_content_type, disposition: :inline)
  end
  
  def eval
  
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gift
      @gift = Gift.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gift_params
      params.require(:gift).permit(:name,:url)
    end
    
    PERMIT_ADDRESSES = ['127.0.0.1', '::1', '119.104.104.23'].freeze

    def restrict_remote_ip
      unless PERMIT_ADDRESSES.include?(request.remote_ip)
      render text: 'Service Unavailable', status: 503
    end
  end
end

