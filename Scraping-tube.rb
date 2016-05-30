require 'tweakphoeus'
require 'nokogiri'
require 'oj'

class Youtube
  URL = "https://www.youtube.com/"
  URL_DOWNLOADER = "http://www.youtube-mp3.org/"
  URL_SONG = "#{URL}watch?v="
  #r and s are js created params... but if u copy and paste this is a party
  R_PARAM = "1464572267644" #r=1464568697773&s=69125
  S_PARAM = "81744"  #r=MjEyLjEyMi45Ni4y&h2=a9172a31e3d43d82e9e260189351b505&s=92539
  #EXAMPLE_VIDEO = "https://www.youtube.com/watch?v=OlKhQgMOKeY"
  EXAMPLE_VIDEO = "https://www.youtube.com/watch?v=F4tjhu847GI"
  URL_ID_COOKIES = "#{URL_DOWNLOADER}a/pushItem/?item=#{EXAMPLE_VIDEO}&el=na&bf=false&r=#{R_PARAM}&s=#{S_PARAM}"
  URL_PARAMS ="#{URL_DOWNLOADER}a/itemInfo/?video_id=$ID&ac=www&t=grp&r=#{R_PARAM}&s=#{S_PARAM}"
  #URL_DOWLOAD = "#{URL_DOWNLOADER}get?video_id=$ID&ts_create=$TS&r=$R&h2=$H2&s=92539" #1464567118&r=MjEyLjEyMi45Ni4y&h2=a9172a31e3d43d82e9e260189351b505&s=92539"
  URL_DOWLOAD = "#{URL_DOWNLOADER}get?video_id=$ID&ts_create=1464568697&r=MjEyLjEyMi45Ni4y&h2=c1c500cdf3edfa1d575ad3f7568c2b83&s=70939" #1464567118&r=MjEyLjEyMi45Ni4y&h2=a9172a31e3d43d82e9e260189351b505&s=92539"


  def initialize
    @http = Tweakphoeus::Client.new()
  end

  def get_songs list_url
    song_list = []

    response = @http.get(list_url)
    page = Nokogiri::HTML(response.body)
    list = page.css('#playlist-autoscroll-list')
    list.css('li').each do |song|
      puts song.attr('data-video-id')
      song_list << URL_SONG + song.attr('data-video-id')
    end

    song_list
  end

  def download_list song_list=[]
    return "Failing song_list" if song_list.is_empty?

    @http.base_headers["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.8.0"
    @http.base_headers["Host"] = "www.youtubeinmp3.com"
    response = @http.get("www.youtubeinmp3.com/fetch/?format=JSON&video=http://www.youtube.com/watch?v=i62Zjga8JOM", redirect: false)
    url = Oj.load(response.body)["link"]
    response = @http.get(url, redirect: false)

    #Apropiate host do faster this proccess
    @http.base_headers["Host"] = response.headers["Location"].split('/')[2]
    response = @http.get("http:" + response.headers["Location"])

  end

end
