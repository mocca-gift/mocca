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
    # @calendars = Calendar.all
    
    render :layout => 'home'
  end
  
  #************************Ajax****************************
  
  #当日に近いギフト・デイを探す
  def nearday
    dayIndex=params[:index].to_i
    
    @calendars = Giftcalendar.where(judge_num: 1)
    
    dayIndex=dayIndex%@calendars.length
    
    
    #keyがカレンダーでバリューが今日の日付からの差
    @calHash = Hash.new(0)
    
    #今年
    @thisYear=Date.today.year
    @today=Date.today
    
    @calendars.each do |cal|
        begin
          @konohi=Date.new(cal.year.to_i ,cal.month.to_i ,cal.day.to_i)
        rescue => e
        logger.error e
        logger.error e.backtrace.join("\n")
        end
        orderNum=(@konohi-@today).to_i
        @calHash[cal]=orderNum
    end
    
    @nearestDay= @calHash.sort_by{|key, value| value}[dayIndex][0]
    @length= @calHash.sort_by{|key, value| value}[dayIndex][1]
    
    render text: '	<div class="nearday_date">'+@nearestDay.month.to_s+'月'+@nearestDay.day.to_s+'日</div>
		<div class="nearday_name"><h3>'+@nearestDay.name+'</h3></div>
		<div class="nearday_for_text"><h4>'+@nearestDay.for_whom+'に</h4></div>
		<div class="nearday_for">プレゼントを渡そう!!</div>'
  end
  
  #芽を探す
  def search_bud
    searchWord  = params[:searchword]
    searchWordArray = searchWord.split(",")
    fromYear = params[:fromyear].to_i
    fromMonth = params[:frommonth].to_i
    fromDay = params[:fromday].to_i
    toYear = params[:toyear].to_i
    toMonth = params[:tomonth].to_i
    toDay = params[:today].to_i
    
    if toYear==0 && toMonth==0 && toDay==0 then
      toYear = 2999
      toMonth = 12
      toDay = 31
    end
    
    @calendars = Giftcalendar.order('year,month,day')
    
    @calendars = @calendars.where('year >= ?', fromYear)
    @calendars = @calendars.where('month >= ?', fromMonth)
    @calendars = @calendars.where('day >= ?', fromDay)
    @calendars = @calendars.where('year <= ?', toYear)
    @calendars = @calendars.where('month <= ?', toMonth)
    @calendars = @calendars.where('day <= ?', toDay)
    
    # @calendars = @calendars.where(judge_num: 0)
    
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
        responseText+='<div class="day_contents_container"><div class="share">
    <div class="share-box"><a class="share-button twitter" href="http://twitter.com/intent/tweet?text='+cal.month.to_s+'月'+cal.day.to_s+'日は'+cal.name+'&url=https://mocca-giftfinder.herokuapp.com" onclick="window.open(encodeURI(decodeURI(this.href)), "tweetwindow", "width=550, height=450, personalbar=0, toolbar=0, scrollbars=1, resizable=1" ); return false;" target="_blank"><i class="fontawesome-twitter"></i>ツイート</a></div>
    <div class="share-box"><a class="share-button facebook" href="http://www.facebook.com/share.php?u=https://mocca-giftfinder.herokuapp.com" onclick="window.open(this.href, "window", "width=550, height=450,personalbar=0,toolbar=0,scrollbars=1,resizable=1"); return false;"><i class="fontawesome-facebook"></i>シェア</a></div>
    <div class="share-box"><a class="share-button line" href="http://line.me/R/msg/text/?'+cal.month.to_s+'月'+cal.day.to_s+'日は'+cal.name+'">LINE</a></div>
    <div class="share-box"><a class="share-button googleCalendar" href="https://www.google.com/calendar/gp?pli=1#~calendar:view=e&bm=1&action=TEMPLATE&text='+cal.name+'&dates='+Date.new(cal.year.to_i,cal.month.to_i,cal.day.to_i).strftime("%Y%m%d")+'/'+Date.new(cal.year.to_i,cal.month.to_i,cal.day.to_i).strftime("%Y%m%d")+'&location=&trp=true&trp=undefined&trp=true&sprop="></a></div>
</div><div class="day_contents type'+cal.judge_num.to_s+'">
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
			</div></div>'
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
        responseText=@calendar.like_count.to_s
      else
        responseText=@calendar.like_count.to_s
      end
    when "down" then
      @calendar=Giftcalendar.find(index)
      @calendar.update(dislike_count: @calendar.dislike_count.to_i+1)
      disNum=@calendar.dislike_count.to_i
      if @calendar.judge_num==0 && @calendar.dislike_count==@limit_num then
        @calendar.destroy
        responseText=disNum.to_s
      else
        responseText=@calendar.dislike_count.to_s
      end
    else
    end
    render text: responseText
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
    year = params[:year]
    month = params[:month]
    day = params[:day]
    if forWhom!="" && dayName!="" && year!="" && month!="" && day!="" then
      Giftcalendar.create(year: year, month: month, day: day, name: dayName, for_whom: forWhom, concept: concept, judge_num: 0 , like_count: 0 , dislike_count: 0)
      responseText="<div><strong>日付:</strong></div>
                      <div>"+year.to_s+"年"+month.to_s+"月"+day.to_s+"日</div>
                    <div><strong>名称:</strong></div>
                      <div>"+dayName+"</div>
                    <div><strong>プレゼントを渡す相手:</strong></div>
                      <div>"+forWhom+"</div>
                    <div><strong>この日のコンセプト:</strong></div>
                      <div>"+concept+"</div>
                    <div>登録されました</div>"
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
  
  def get_calendar
    @year=params[:year].to_i
    @month=params[:month].to_i
    responseText='<table class="show_calendar">
					<thead>
						<tr>
							<th>日</th>
							<th>月</th>
							<th>火</th>
							<th>水</th>
							<th>木</th>
							<th>金</th>
							<th>土</th>
						</tr>
					</thead>
					<tbody>'
    for i in 1..42 do
      case i%7
      when 1 then
        if getDate(@year,@month,i)=="" then
          responseText+='<tr><td>'+getDate(@year,@month,i)+'</td>'
        else
          if Giftcalendar.where(year: @year, month: @month, day: getDate(@year,@month,i)).empty? then
            responseText+='<tr><td class="border_line">'+getDate(@year,@month,i)+'</td>'
          else
            responseText+='<tr><td class="border_line"><a  class="exist" href="javascript:void(0);" onclick="getInfo('+@year.to_s+','+@month.to_s+','+getDate(@year,@month,i)+')">'+getDate(@year,@month,i)+'</a></td>'
          end
        end
      when 0 then
        if getDate(@year,@month,i)=="" then
          responseText+='<td>'+getDate(@year,@month,i)+'</td></tr>'
        else
          if Giftcalendar.where(year: @year, month: @month, day: getDate(@year,@month,i)).empty? then
            responseText+='<td class="border_line">'+getDate(@year,@month,i)+'</td></tr>'
          else
            responseText+='<td class="border_line"><a  class="exist" href="javascript:void(0);" onclick="getInfo('+@year.to_s+','+@month.to_s+','++getDate(@year,@month,i)+')">'+getDate(@year,@month,i)+'</a></td></tr>'
          end
        end
      else
        if getDate(@year,@month,i)=="" then
          responseText+='<td>'+getDate(@year,@month,i)+'</td>'
        else
          if Giftcalendar.where(year: @year, month: @month, day: getDate(@year,@month,i)).empty? then
            responseText+='<td class="border_line">'+getDate(@year,@month,i)+'</td>'
          else
            responseText+='<td class="border_line"><a  class="exist" href="javascript:void(0);" onclick="getInfo('+@year.to_s+','+@month.to_s+','++getDate(@year,@month,i)+')">'+getDate(@year,@month,i)+'</a></td>'
          end
        end
      end
    end
    
    responseText+='</tbody>
				</table>'
		
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
    
    def getDate(year,month,index)
      @diff = Date.new(year,month,1).wday
      res   = index-@diff
      if res<1 then
        res=""
      else
        if month==12 then
          if res>(Date.new(year+1,1,1)-Date.new(year,month,1)) then
            res=""
          end
        else
          if res>(Date.new(year,month+1,1)-Date.new(year,month,1)) then
            res=""
          end
        end
      end
      
      return res.to_s
    end
end
