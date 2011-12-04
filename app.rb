# coding: utf-8
require 'yaml'
require 'sinatra/reloader' if development?

configure do
  enable :session
  pusher_conf = YAML::load_file('./config/pusher.yml')[ENV['RACK_ENV']]
  %w(app_id key secret).each do |k|
    Pusher.send("#{k}=", pusher_conf[k])
  end
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/style.css' do
  scss :style
end

get '/' do
  erb :index
end

# GET /test?message=helloworld
get '/test' do
  message = params[:message]
  Pusher['test_channel'].trigger('my_event', message)
end
