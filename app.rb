# coding: utf-8
require 'yaml'
require 'json'
require 'uri'
require 'pp'
require 'sinatra/reloader' if development?

configure do
  enable :sessions
  pusher_conf = YAML::load_file('./config/pusher.yml')[ENV['RACK_ENV']]
  %w(app_id key secret).each do |k|
    Pusher.send("#{k}=", pusher_conf[k])
  end

  oauth_conf = YAML::load_file('./config/oauth.yml')[ENV['RACK_ENV']]['twitter']
  use OmniAuth::Builder do
    provider :twitter, oauth_conf['key'], oauth_conf['secret']
  end
  
  DB = Redis.new
  slide_conf = YAML::load_file('./config/slideshare.yml')
  Slide = SlideShare::Base.new(api_key: slide_conf['key'], shared_secret: slide_conf['secret'])
end

class User
  attr_accessor :uid, :nickname, :image

  def initialize(hash)
    @uid      = hash['uid']
    @nickname = hash['nickname']
    @image    = hash['image']
  end
  def to_hash
    {uid: @uid,
     nickname: @nickname,
     image: @image}
  end
  def to_json
    to_hash.to_json
  end
  def save
    DB.set("User:#{@uid}", to_json)
  end
  def self.create(hash)
    user = self.new(hash)
    user.save
    user
  end
  def self.get(uid)
    hash = DB.get("User:#{uid}")
    if hash.present?
      self.new(JSON::parse(hash))
    else
      nil
    end
  end
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def login(auth)
    hash = {'uid' => auth['uid'],
            'nickname' => auth['info']['nickname'],
            'image' => auth['info']['image']}
    user = User.create(hash)
    session[:uid] = user.uid
  end
  def current_user
    return nil unless logged_in?
    User.get(session[:uid])
  end
  def logged_in?
    session[:uid].present?
  end
  def logout
    session.clear
  end
  def exit_room(user)
    room_id = session[:current_room_id]
    return if room_id.nil? || user.nil?
    key = "Room:#{room_id}"
    DB.zrem(key, user.uid)
  end
  def enter_room(room_id, user)
    key = "Room:#{room_id}"
    DB.zadd(key, DB.zcount(key, '-inf', '+inf'), user.uid)
    session[:current_room_id] = room_id
  end
end

module SlideShare
  class Slideshows
    def find_by_url(url, options = {})
      detailed = convert_to_number(options.delete(:detailed))
      options[:detailed] = detailed unless detailed.nil?
      base.send :get, "/get_slideshow", options.merge(:slideshow_url => url)
    end
  end
end

get '/style.css' do
  scss :style
end

get '/' do
  erb :index, locals: {slide_id: nil, slide: {}}
end

post '/slide' do
  slide_id = Rack::Utils.escape(params[:slide_id])
  if slide_id.nil?
    redirect to('/')
  end
  redirect to("/slide/#{slide_id}")
end

get '/slide/:slide_id' do
  # ログインしていない場合はトップへ
  redirect to('/') unless logged_in?
  slide_id = Rack::Utils.unescape(params[:slide_id])
  if slide_id.nil?
    redirect to('/')
  end

  res = Slide.slideshows.find_by_url(slide_id, detailed: true)
  slide_data = res['Slideshow']

  slide = {id: slide_data['ID'],
          doc: slide_data['PPTLocation'],
          title: slide_data['Title'],
          desc: slide_data['Description']}

  # 入退室
  exit_room(current_user)
  enter_room(slide[:id], current_user)

  # 閲覧者を取得
  members = DB.zrange("Room:#{slide[:id]}", 0, -1)
  members.map!{|uid| User.get(uid)}

  # slideの情報やユーザーの情報を取得してviewに渡す
  erb :index, locals: {slide_id: slide_id, slide: slide, members: members}
end

get '/auth/twitter/callback' do
  login env['omniauth.auth']
  redirect to('/')
end

# GET /test?message=helloworld
get '/test' do
  message = params[:message]
  Pusher['test_channel'].trigger('my_event', message)
end

# 本運用では必要ないかもしれないがデバッグ用に
get '/logout' do
  exit_room(current_user)
  logout
  redirect to('/')
end
