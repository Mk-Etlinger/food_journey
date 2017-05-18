require './config/environment'
require 'rack-flash'

class ApplicationController < Sinatra::Base 

  configure do
    enable :sessions
    set :public_folder, 'public'
    set :views, 'app/views'
    set :session_secret, "food_journey"
    use Rack::Flash, :sweep => true
  end

  get '/' do

    haml :index
  end

  get '/signup' do

    haml :'registration/signup'
  end
  
  post '/signup' do
    @user = User.new(params) unless user_exists?

    if @user&.save
      session[:id] = @user.id
      redirect_to_dashboard
    else
      flash[:message] = "username or email already exists"
      redirect "/signup"
    end
    
  end
  
  get '/login' do
    
    haml :login
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:id] = @user.id
      redirect_to_dashboard
    else
      redirect "/login"
    end
  end

  get '/logout' do
    session.clear
    redirect "/login"
  end

  helpers do
    def logged_in?
      !!session[:id]
    end
    
    def current_user
      @user ||= User.find(session[:id])
    end

    def authenticate_user
      redirect("/login") if !logged_in?
    end

    def redirect_to_dashboard
      redirect "/dashboard/#{current_user.username}"
    end
    
    def user_exists?
     User.where("username = ? OR email = ?", params[:username], params[:email])
    end
    

  end

  


end


