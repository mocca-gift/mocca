class InfosController < ApplicationController
  before_action :set_info, only: [:show, :edit, :update, :destroy, :img]
  before_action :restrict_remote_ip, except: [:img]
  
  
  PERMIT_ADDRESSES = ['127.0.0.1', '::1', ENV['MY_IP_ADDRESS']]

  # GET /infos
  # GET /infos.json
  def index
    @infos = Info.all
  end

  # GET /infos/1
  # GET /infos/1.json
  def show
  end

  # GET /infos/new
  def new
    @info = Info.new
  end

  # GET /infos/1/edit
  def edit
  end

  # POST /infos
  # POST /infos.json
  def create
    @info = Info.new(info_params)
    #画像が登録されていなかったらid１の画像を設定する
    if params[:info][:img] !=nil
      @info.img = params[:info][:img].read # <= バイナリをセット
      @info.img_content_type = params[:info][:img].content_type # <= ファイルタイプをセット
    else
      @info.img = info.find(1).img
      @info.img_content_type = info.find(1).img_content_type
    end

    respond_to do |format|
      if @info.save
        format.html { redirect_to @info, notice: 'info was successfully created.' }
        format.json { render :show, status: :created, location: @info }
      else
        format.html { render :new }
        format.json { render json: @info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /infos/1
  # PATCH/PUT /infos/1.json
  def update
    respond_to do |format|
      if @info.update(info_params)
        if params[:info][:img] !=nil
          @info.update(:img => params[:info][:img].read) # <= バイナリをセット
          @info.update(:img_content_type => params[:info][:img].content_type) # <= ファイルタイプをセット
        else
          @info.update(:img => info.find(1).img) # <= バイナリをセット
          @info.update(:img_content_type => info.find(1).img_content_type) # <= ファイルタイプをセット
        end
        format.html { redirect_to @info, notice: 'info was successfully updated.' }
        format.json { render :show, status: :ok, location: @info }
      else
        format.html { render :edit }
        format.json { render json: @info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /infos/1
  # DELETE /infos/1.json
  def destroy
    @info.destroy
    respond_to do |format|
      format.html { redirect_to infos_url, notice: 'info was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def img
  send_data(@info.img, type: @info.img_content_type, disposition: :inline)
  end
  
  def eval
  
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_info
      @info = Info.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def info_params
      params.require(:info).permit(:title,:content)
    end
    
    def restrict_remote_ip
    unless PERMIT_ADDRESSES.include?(request.remote_ip)
      render text: 'Service Unavailable', status: 503
    end
    end
end
