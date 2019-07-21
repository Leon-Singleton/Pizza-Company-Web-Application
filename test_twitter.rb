require 'twitter'
require 'omniauth-twitter'
config = {
    :consumer_key => '5e0ZtD8Ar8qOpih52ljqq647Z',
    :consumer_secret => '5otIuyiETzis0QtI2rKmCtuCvyWNAhP4VDoPJZViQKQ2DakGub',
    :access_token =>  '836528282011062272-GqzwljW60TnOq5WYprXG6Qk035Uz8m4',
    :access_token_secret => 'jnAJVjAgtjGhRTXS5oMvpiDDTqqrIwHn52EAWCi6BCJgp'
}
client = Twitter::REST::Client.new(config)

configure do
  enable :sessions

  use OmniAuth::Builder do
    provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
  end
end

# Code provided by http://recipes.sinatrarb.com/p/middleware/twitter_authentication_with_omniauth
# If you can make more sense of it, please write whatever is necessary here

helpers do
  # define a current_user method, so we can be sure if an user is authenticated
  def current_user
    !session[:uid].nil?
  end
end

before do
  # we do not want to redirect to twitter when the path info starts
  # with /auth/
  pass if request.path_info =~ /^\/auth\//

  # /auth/twitter is captured by omniauth:
  # when the path info matches /auth/twitter, omniauth will redirect to twitter
  redirect to('/auth/twitter') unless current_user
end


get '/login' do
  # probably you will need to create a user in the database too...
  session[:uid] = env['omniauth.auth']['uid']
  # this is the main endpoint to your application
  redirect to('/')
end

get '/auth/failure' do
  # omniauth redirects to /auth/failure when it encounters a problem
  # so you can implement this as you please
end

get '/' do
  'Hello omniauth-twitter!'
end