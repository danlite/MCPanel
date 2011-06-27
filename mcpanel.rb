require 'rubygems'
require 'sinatra'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'mcpanel' and password == 'password'
end

get '/' do
  "Hello from Sinatra on Heroku!"
end