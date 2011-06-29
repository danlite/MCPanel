require 'rubygems'
require 'sinatra'
require 'aws'
require 'aws/ec2'
require 'haml'
require 'sass'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'mcpanel' and password == ENV['MCPANEL_AUTH_PASSWORD']
end

helpers do
  def ec2_handle
    AWS::EC2::Base.new(:access_key_id => ENV['AWS_KEY'], :secret_access_key => ENV['AWS_SECRET'])
  end
end

get '/' do
  ec2 = ec2_handle
  
  result = ec2.describe_instances(:instance_id => ENV['MC_EC2_INSTANCE_ID'])
  instance = result.reservationSet.item.first.instancesSet.item.first
  @state = instance.instanceState.name
  
  haml :index
end

get '/start_server' do
  ec2_handle.start_instances(:instance_id => ENV['MC_EC2_INSTANCE_ID'])
  "Server has been started. It will be ready shortly."
end

get '/stylesheet.css' do
  sass :stylesheet
end