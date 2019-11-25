require 'sinatra'

class App < Sinatra::Base
  get '/' do
    'hello, sinatra'
  end
end

run App.new
