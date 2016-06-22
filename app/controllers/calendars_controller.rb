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
    
    # #keyがカレンダーでバリューが今日の日付からの差
    # @calHash = Hash.new(0)
    
    # #今年
    # @thisYear=Date.today.year
    # @today=Date.today.yday
    
    # @calendars.each do |cal|
    #     begin
    #       @konohi=Date.new(@thisYear.to_i,cal.month.to_i,cal.day.to_i)
    #     rescue => e
    #     logger.error e
    #     logger.error e.backtrace.join("\n")
    #     end
    #     @sa=@konohi.yday-@today
    #     if @sa<0 then
    #       orderNum=365+@sa
    #     else
    #       orderNum=@sa
    #     end
    #     @calHash[cal]=orderNum
    # end
    
    # @nearestDay= @calHash.sort_by{|key, value| value}[0][0]
    # @length= @calHash.sort_by{|key, value| value}[0][1]
    
    render :layout => 'home'
  end
  
  def nearday
    dayIndex=params[:index].to_i
    
    @calendars = Giftcalendar.where(judge_num: 1)
    
    dayIndex=dayIndex%@calendars.length
    
    
    #keyがカレンダーでバリューが今日の日付からの差
    @calHash = Hash.new(0)
    
    #今年
    @thisYear=Date.today.year
    @today=Date.today.yday
    
    @calendars.each do |cal|
        begin
          @konohi=Date.new(@thisYear.to_i,cal.month.to_i,cal.day.to_i)
        rescue => e
        logger.error e
        logger.error e.backtrace.join("\n")
        end
        orderNum=(@konohi.yday-@today)%365
        @calHash[cal]=orderNum
    end
    
    @nearestDay= @calHash.sort_by{|key, value| value}[dayIndex][0]
    @length= @calHash.sort_by{|key, value| value}[dayIndex][1]
    
    render text: '	<div class="nearday_date">'+@nearestDay.month.to_s+'月'+@nearestDay.day.to_s+'日</div>
		<div class="nearday_name"><h3>'+@nearestDay.name+'</h3></div>
		<div class="nearday_for_text"><h4>こんな人にプレゼントを渡そう!!</h4></div>
		<div class="nearday_for">'+@nearestDay.for_whom+'</div>'
  end
  
  def search_bud
    searchWord  = params[:searchword]
    searchWordArray = searchWord.split(",")
    # fromMonth = params[:frommonth].to_i
    # fromDay = params[:fromday].to_i
    # toMonth = params[:tomonth].to_i
    # toDay = params[:today].to_i
    
    # case fromDay
    # when 0 then
    #   fromDay=1
    # when (1..12) then
    # else
    #   fromDay=
    
    # if fromMonth==0 then
    #   fromMonth==1
    # else
    #   if fromMonth>12 then
        
    # end
    
    
    # if 
    
    # @calendars = Calendar.order('month, day')
    
    # #keyがカレンダーオブジェクトでvalueがyday
    # @calHash = Hash.new(0)
    
    # @thisYear=Date.today.year
    # begin
    #   @fromDate=Date.new(@thisYear.to_i,fromMonth,fromDay)
    #   @fromDateYday=Date.new(@thisYear.to_i,fromMonth,fromDay).yday
    # rescue => e
    # logger.error e
    # logger.error e.backtrace.join("\n")
    # end
    
    # # @fromDateYday=Date.new(@thisYear.to_i,fromMonth,fromDay).yday
    
    # begin
    #   @toDate=Date.new(@thisYear.to_i,toMonth,toDay)
    #   @toDateYday=Date.new(@thisYear.to_i,toMonth,toDay).yday
    # rescue => e
    # logger.error e
    # logger.error e.backtrace.join("\n")
    # end
    
    # # @toDateYday=Date.new(@thisYear.to_i,toMonth,toDay).yday
    
    # @calendars.each do |cal|
    #     begin
    #       @konohi=Date.new(@thisYear.to_i,cal.month.to_i,cal.day.to_i)
    #       @calHash[cal]=@konohi.yday
    #     rescue => e
    #     logger.error e
    #     logger.error e.backtrace.join("\n")
    #     end
    #     # @calHash[cal]=@konohi.yday
    # end
    
    # @calendars= @calHash.select {|k,v| v>=@fromDateYday }.select {|k,v| v<=@toDateYday }.keys
    @calendars = Giftcalendar.order('month,day')
    @calendars = @calendars.where(judge_num: 0)
    searchWordArray.each do |swa|
      @calendars=@calendars.where("name like '%" + swa + "%' OR for_whom like '%" + swa +"%'")
    end
    responseText=""
    if @calendars.empty? then
      responseText="<div>該当する結果はありません</div>"
    else
      num = @calendars.count
      #responseText="<div class='gdtitle'>該当するギフトデーが"+num.to_s+"件あります</div>"
      @calendars.each do |cal|
        responseText+='<div class="day_contents">
				<div class="day_date">'+cal.month.to_s+'月'+cal.day.to_s+'日</div>
				<div class="day_name">'+cal.name+'</div>
				<div class="day_concept">'+cal.concept+'</div>
				<div class="day_for_title">こんな人にプレゼントを渡そう!!</div>
				<div class="day_for">'+cal.for_whom+'</div>
				<div class="day_evals">
				    <div class="day_eval" id="like_eval">
						<a href="javascript:void(0);" class="day_evalbtn cal_eval_like'+cal.id.to_s+'" id="likebtn" onclick="evalup('+cal.id.to_s+');"></a>
						<div class="day_evalnum cal_like'+cal.id.to_s+'" id="likenum">'+cal.like_count.to_s+'</div>
					</div>
					<div class="day_eval" id="dislike_eval">
						<a href="javascript:void(0);" class="day_evalbtn cal_eval_dislike'+cal.id.to_s+'" id="dislikebtn" onclick="evaldown('+cal.id.to_s+');"></a>
						<div class="day_evalnum cal_dislike'+cal.id.to_s+'" id="dislikenum">'+cal.dislike_count.to_s+'</div>
				    </div>	
				</div>
			</div>'
      end
    end
    render text: responseText
  end
  
  def search_flower
    searchWord  = params[:searchword]
    searchWordArray = searchWord.split(",")
    @calendars = Giftcalendar.order('month,day')
    @calendars = @calendars.where(judge_num: 1)
    searchWordArray.each do |swa|
      @calendars=@calendars.where("name like '%" + swa + "%' OR for_whom like '%" + swa +"%'")
    end
    responseText=""
    if @calendars.empty? then
      responseText="<div>該当する結果はありません</div>"
    else
      num = @calendars.count
      #responseText="<div class='gdtitle'>該当するギフトデーが"+num.to_s+"件あります</div>"
      @calendars.each do |cal|
        responseText+='<div class="day_contents">
				<div class="day_date">'+cal.month.to_s+'月'+cal.day.to_s+'日</div>
				<div class="day_name">'+cal.name+'</div>
				<div class="day_concept">'+cal.concept+'</div>
				<div class="day_for_title">こんな人にプレゼントを渡そう!!</div>
				<div class="day_for">'+cal.for_whom+'</div>
				<div class="day_evals">
				    <div class="day_eval" id="like_eval">
						<a href="javascript:void(0);" class="day_evalbtn cal_eval_like'+cal.id.to_s+'" id="likebtn" onclick="evalup('+cal.id.to_s+');"></a>
						<div class="day_evalnum cal_like'+cal.id.to_s+'" id="likenum">'+cal.like_count.to_s+'</div>
					</div>
					<div class="day_eval" id="dislike_eval">
						<a href="javascript:void(0);" class="day_evalbtn cal_eval_dislike'+cal.id.to_s+'" id="dislikebtn" onclick="evaldown('+cal.id.to_s+');"></a>
						<div class="day_evalnum cal_dislike'+cal.id.to_s+'" id="dislikenum">'+cal.dislike_count.to_s+'</div>
				    </div>	
				</div>
			</div>'
      end
    end
    render text: responseText
  end
  
  
  def eval
    @limit_num=5
    index=params[:index].to_i
    type=params[:type]
    case type
    when "up" then
      @calendar=Giftcalendar.find(index)
      @calendar.update(like_count: @calendar.like_count.to_i+1)
      if @calendar.like_count==@limit_num then
        @calendar.update(judge_num: 1)
        responseText="Upgraded"
      else
        responseText=@calendar.like_count.to_s
      end
    when "down" then
      @calendar=Giftcalendar.find(index)
      @calendar.update(dislike_count: @calendar.dislike_count.to_i+1)
      if @calendar.judge_num==0 && @calendar.dislike_count==@limit_num then
        @calendar.destroy
        responseText="Destroyed"
      else
        responseText=@calendar.dislike_count.to_s
      end
    else
    end
    render text: responseText
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
    concept = params[:concept]
    month = params[:month]
    day = params[:day]
    if Giftcalendar.where(name: dayName).empty? && forWhom!="" then
      Giftcalendar.create(month: month, day: day, name: dayName, for_whom: forWhom, concept: concept, judge_num: 0 , like_count: 0 , dislike_count: 0)
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
