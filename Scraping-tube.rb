require 'tweakphoeus'
require 'nokogiri'
require 'oj'

class Youtube
  URL = "https://www.youtube.com/"
  URL_DOWNLOADER = "http://www.youtube-mp3.org/"
  URL_SONG = "#{URL}watch?v="
  EX_VIDEO = "https://www.youtube.com/watch?v=OlKhQgMOKeY"
  HOST = "www.youtubeinmp3.com"
  USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.8.0"
  URL_DOWNLOAD = "www.youtubeinmp3.com/fetch/?format=JSON&video=$LINK"

  def initialize
    @http = Tweakphoeus::Client.new()
  end

  def get_songs list_url="https://www.youtube.com/watch?v=-uYOlj51dgQ&list=PL75E6204957B76A65"
    song_list = []

    response = @http.get(list_url)
    page = Nokogiri::HTML(response.body)
    list = page.css('#playlist-autoscroll-list')
    list.css('li').each do |song|
      next if song.attr('data-video-title') == "[Vídeo eliminado]" || song.attr('data-video-title') == "[Vídeo privado]"
      id = song.attr('data-video-id')
      name = song.attr('data-video-title')
      puts "#{URL_SONG + song.attr('data-video-id')} | #{song.attr('data-video-title')}"
      song_list << [
        id,
        name
      ]
    end

    song_list
  end

  def download_list song_list=[]
    return "Error. Song list empty." if song_list.empty?
    @http.base_headers["User-Agent"] = USER_AGENT
    @http.base_headers["Host"] = HOST

    song_list.each do |track|
      begin
        url = URL_SONG + track.first
        response = @http.get(URL_DOWNLOAD.gsub("$LINK", url), redirect: false)

        url = Oj.load(response.body)["link"]
        response = @http.get(url, redirect: false)

        @http.base_headers["Host"] = response.headers["Location"].split('/')[2]
        response = @http.get("http:" + response.headers["Location"])
        save_track(response.body, track.last)
        sleep 10
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
    end

  end

  def save_track song, name
    a = File.open("#{name}.mp3","w")
    a.write(song)
    a.close
  end

end
