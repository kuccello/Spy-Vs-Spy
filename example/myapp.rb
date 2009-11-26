require 'haml'
require 'sinatra/base'

class MyApp < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/views'
  set :public, File.dirname(__FILE__) + '/public'
  set :root, File.dirname(__FILE__)
  set :static, true

  get '/' do
    haml :index
  end

end
