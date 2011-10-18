require 'rubygems'
require 'sinatra'
require 'AWS'
require 'haml'
require 'sass'

enable :sessions

USERNAME = 'mcpanel'

def authenticate_user(password)
  password == ENV['MCPANEL_AUTH_PASSWORD']
end

def logged_in
  session['username']
end

helpers do
  def ec2_handle
    AWS::EC2::Base.new(:access_key_id => ENV['AWS_KEY'], :secret_access_key => ENV['AWS_SECRET'])
  end
end

get '/' do
  redirect '/login' unless logged_in
  
  ec2 = ec2_handle
  
  result = ec2.describe_instances(:instance_id => ENV['MC_EC2_INSTANCE_ID'])
  instance = result.reservationSet.item.first.instancesSet.item.first
  @state = instance.instanceState.name
  
  haml :index
end

get '/start_server' do
  ec2_handle.start_instances(:instance_id => ENV['MC_EC2_INSTANCE_ID'])
  "Server has been started. It will be ready in a couple minutes."
end

get '/logout' do
  session['username'] = nil
  
  redirect '/login'
end

get '/login' do
  redirect '/' if logged_in
  
  haml :login
end

post '/login' do
  if authenticate_user(params[:password])
    session['username'] = USERNAME
    redirect '/'
  else
    redirect '/login'
  end
end

get '/stylesheet.css' do
  sass :stylesheet
end