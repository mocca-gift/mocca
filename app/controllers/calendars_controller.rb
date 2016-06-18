class CalendarsController < ApplicationController
  before_action :set_calendar, only: [:show, :edit, :update, :destroy]
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

  # GET /calendars
  # GET /calendars.json
  def index
    @calendars = Calendar.all
  end

  # GET /calendars/1
  # GET /calendars/1.json
  def show
  end

  # GET /calendars/new
  def new
    @calendar = Calendar.new
  end

  # GET /calendars/1/edit
  def edit
  end

  # POST /calendars
  # POST /calendars.json
  def create
    @calendar = Calendar.new(calendar_params)

    respond_to do |format|
      if @calendar.save
        format.html { redirect_to @calendar, notice: 'Calendar was successfully created.' }
        format.json { render :show, status: :created, location: @calendar }
      else
        format.html { render :new }
        format.json { render json: @calendar.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /calendars/1
  # PATCH/PUT /calendars/1.json
  def update
    respond_to do |format|
      if @calendar.update(calendar_params)
        format.html { redirect_to @calendar, notice: 'Calendar was successfully updated.' }
        format.json { render :show, status: :ok, location: @calendar }
      else
        format.html { render :edit }
        format.json { render json: @calendar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /calendars/1
  # DELETE /calendars/1.json
  def destroy
    @calendar.destroy
    respond_to do |format|
      format.html { redirect_to calendars_url, notice: 'Calendar was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def getevent
    month=params[:month]
    day=params[:day]
    @calendars=Calendar.where(month: month, day: day)
    responseText="<div>"+month+"月"+day+"日は...</div>"
    if Calendar.where(month: month, day: day).empty? then
      responseText+="まだギフトデーが登録されていません..."
    else
      @calendars.each do |cal|
        responseText+="<div class='gddata'><p><strong>"+cal.name1+"</strong></p><p>For "+cal.name2+"</p><p class='datestr'></div>"
      end
    end
    render text: responseText
  end
  
  def search
    searchWord  = params[:searchword]
    searchWordArray = searchWord.split(",")
    @calendars = Calendar.all
    searchWordArray.each do |swa|
      @calendars=@calendars.where("name1 like '%" + swa + "%' OR name2 like '%" + swa +"%'")
    end
    
    if @calendars.empty? then
      responseText="該当する結果はありません"
    else
      num = @calendars.count
      responseText="<div class='gdtitle'>該当するギフトデーが"+num.to_s+"件あります</div>"
      @calendars.each do |cal|
        responseText+="<div class='gddata'><p><strong>"+cal.name1+"</strong></p><p>For "+cal.name2+"</p><p class='datestr'>"+cal.month.to_s+"月"+cal.day.to_s+"日</p></div>"
      end
    end
    
    render text: responseText
  end
  
  def ajaxcreate
    dayName = params[:dayname]
    forWhom = params[:forwhom]
    month = params[:month]
    day = params[:day]
    if Calendar.where(name1: dayName).empty? && forWhom!="" then
      Calendar.create(month: month, day: day, name1: dayName, name2: forWhom )
      responseText="<strong>"+dayName+"</strong>は無事登録されました"
    else
      responseText="登録に失敗しました"
    end
    
    render text: responseText
  end
  
  def daynameconf
    dayName = params[:dayname]
    @calendars=Calendar.where(name1: dayName)
    if @calendars.empty? then
      responseText="true"
    else
      responseText="その名称は既に登録されています"
    end
    
    render text: responseText
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_calendar
      @calendar = Calendar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def calendar_params
      params.require(:calendar).permit(:month, :day, :name1, :name2, :name3)
    end
end
