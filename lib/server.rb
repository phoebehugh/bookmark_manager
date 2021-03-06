require 'data_mapper'
require 'sinatra/base'
require 'rack-flash'

env = ENV['RACK_ENV'] || 'development'
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link'
require './lib/tag'
require './lib/user'

DataMapper.finalize
DataMapper.auto_upgrade!

# A class to create our bookmark manager using sinatra 0_o
class BookmarkManager < Sinatra::Base
  set :views, proc { File.join(root, '..', 'views') }

  enable :sessions
  use Rack::Flash
  use Rack::MethodOverride
  set :session_secret, 'super secret'

  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    tags = params['tags'].split(' ').map do |tag|
      Tag.first_or_create(text: tag)
    end
    url = params['url']
    title = params['title']
    Link.create(url: url, title: title, tags: tags)
    redirect to('/')
  end

  get '/tags/:text' do
    tag = Tag.first(text: params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    @user = User.create(email: params[:email],
                        password: params[:password],
                        password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'users/new'
    end
  end

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id]) if session[:user_id]
    end
  end

  post '/forgotten_password' do
    erb :'sessions/forgotten_password'
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  delete '/sessions' do
    flash[:notice] = 'Good bye!'
    session[:user_id] = nil
    redirect to '/'
  end

  post '/sessions' do
    email, password = params[:email], params[:password]
    user = User.authenticate(email, password)
    if user
      session[:user_id] = user.id
      redirect to('/')
    else
      flash[:errors] = ['The email or password is incorrect']
      erb :'sessions/new'
    end
  end
end
