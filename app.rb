# coding: utf-8
require 'yaml'
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
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def login(auth)
    hash = {uid: auth['uid'],
            nickname: auth['info']['nickname'],
            image: auth['info']['image']}
    user = User.get_or_create(hash)
    session[uid] = user.uid
  end
  def logged_in?
    session[:uid].present?
  end
  def logout
    session.clear
  end
end

get '/style.css' do
  scss :style
end

get '/' do
  pp session
  erb :index
end

get '/slide/:slide_id' do
  # ログインしていない場合はトップへ
  redirect to('/') unless logged_in?

  # slideの情報やユーザーの情報を取得してviewに渡す

  erb :index
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
  logout
  redirect to('/')
end
