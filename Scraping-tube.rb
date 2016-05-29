require 'tweakphoeus'
require 'nokogiri'

class Youtube
  URL = "https://www.youtube.com/"
  URL_SONG = "#{URL}watch?v="


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

  def donwload_list song_list=[]
    return "Fallo" if song_list.is_empty?

  end

end
