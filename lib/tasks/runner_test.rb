require 'rss'

class Tasks::RunnerTest
  def self.execute
    rss_source = "http://giftnewsdaily.com/feed/"

    begin
      rss = RSS::Parser.parse(rss_source, true)
    rescue RSS::Error
    end

    rss.items.each do |item|
      # if Topic.where(:title => item.title) then
      # else
      topic = Topic.new
      p item.title
      topic.title = item.title
      topic.link = item.link
      topic.pubDate = item.pubDate
      imgCheck = item.content_encoded.match(/(src="http:)[\S]+((\.jpg)|(\.JPG)|(\.jpeg)|(\.JPEG)|(\.gif)|(\.GIF)|(\.png)|(\.PNG))/); 
      if imgCheck then
          topic.img = imgCheck[0]
      else
      end
      topic.save
    end
  end
end