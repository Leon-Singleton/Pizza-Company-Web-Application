require 'sinatra' 
require_relative 'front_end'
require_relative 'back_end'
require_relative 'error_handling'
set :bind,  '0.0.0.0'  # Only needed if you re running from Codio

include ERB::Util

before do
    @db = SQLite3::Database.new('useraccounts.sqlite')
end

enable :sessions
set :session_secret, 'super secret'
