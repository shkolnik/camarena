require 'rubygems'
require 'bundler/setup'

# gem 'mechanize'
require 'mechanize'
require 'json'
require 'open-uri'

module Xfinity
  BASE_URL = "http://xfinitytv.comcast.net"

  def self.agent
    return @a if @a
    @a = Mechanize.new
    @a.user_agent_alias = 'Windows Mozilla'
    @a
  end

  def self.get_index(index_url)
    p = agent.get(index_url)
    p.links.map{ |link| 
      h = Hash[*link.attributes.to_a.flatten] 
      h["name"] = link.text
      h["cid"] = h["data-v"].split("/")[-3] if h["data-v"]
      h
    }
  end
  
  def self.get_movie_index
    get_index("#{BASE_URL}/movies_db_xtv3.widget")
  end
  
  def self.get_tv_index
    get_index("#{BASE_URL}/full_episodes_db_xtv3.widget")
  end
  

  def self.get_movie_detail( movie )
    detail_url = "#{BASE_URL}/api/video/summary/Video-#{movie["cid"]}?type=json"
    JSON.load( open(detail_url).read )
  end
  
  def self.enhance_movie_with_detail( movie )
    movie.merge( get_movie_detail( movie ) )
  end
  
  class Movie
    attr_accessor :attributes

    def initialize( id )
      detail_url = "#{BASE_URL}/api/video/summary/Video-#{id}?type=json"
      self.attributes = JSON.load( open(detail_url).read )
    end
    
    def title
      attributes["name"]
    end
    
    def duration
      seg = attributes["runningTime"].split(":").map(&:to_i)
      seg[0] * 60 + seg[1]
    end
    
    def release_year
      attributes["releaseYear"]
    end
    
    def description
      attributes["description"]
    end
    
    def watch_url
      "#{BASE_URL}#{entity_base_path}/#{video_id}/#{dasherized_title}/videos"
    end
    
    def imdb_details
      query = URI::encode("title=#{title}&year=#{release_year}")
      url = "http://imdbapi.org/?#{query}&type=json&plot=full&episode=0&limit=1&yg=1&mt=none&lang=en-US&offset=&aka=simple&release=simple"
      JSON.load( open(url).read )
    end
    
    private
    def video_id
      attributes["videoGlobalUid"][6..-1]
    end
    
    def entity_base_path
      attributes["entityUrl"].gsub(/movies$/, "")
    end
    
    def dasherized_title
      attributes["entityUrl"].match(/watch\/([^\/]*)\//)[1]
    end
      
  end
  
  class Series
    attr_accessor :detail_page, :episodes
    
    def initialize( url_or_show )
      if url_or_show.is_a?(Hash)
        url = "#{BASE_URL}#{url_or_show["href"]}"
      else
        url = url_or_show.to_s
      end
    
      self.detail_page = Xfinity.agent.get(url)
      
      eps = detail_page.search("tr.online[itemprop='episode']")
      self.episodes = eps.map{|ep| extract_episode_detail( ep ) }
    end
    
    def extract_episode_detail( ep )
      all_elems = ep.search("*") << ep
    
      attrs = all_elems.map{ |elem| 
            elem.attributes.map{ |name, attr| 
              [name.gsub(/data-/, ""), attr.value] if name =~ /data-/
              }.compact
      }
      
      attrs_hash = Hash[*attrs.flatten]
    
      # all_elems.each do |elem|
      #       prop = elem.attributes["itemprop"].value if elem.attributes["itemprop"]
      #       val = elem.attributes["content"].value if elem.attributes["content"]
      #       attrs[prop] = val if prop && val
      #     end
    end
  end

end