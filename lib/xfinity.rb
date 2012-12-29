# gem 'mechanize'
require 'mechanize'
require 'json'
require 'open-uri '

a = Mechanize.new
a.user_agent_alias = 'Windows Mozilla'

p = agent.get("http://xfinitytv.comcast.net/movies_db_xtv3.widgets")
movies = p.links.map{ |link| 
h = Hash[*link.attributes.to_a.flatten] 
h["name"] = link.text
h["cid"] = h["data-v"].split("/")[-3] if h["data-v"]
h
}

def get_movie_detail( movie )
detail_url = "http://xfinitytv.comcast.net/api/video/summary/Video-#{movie["cid"]}?type=json"
JSON.load( open(detail_url).read )
end
