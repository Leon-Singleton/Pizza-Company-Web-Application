#controller for error pages

require 'sinatra' 
#require 'sinatra/reloader'
set :bind,  '0.0.0.0'  # Only needed if you re running from Codio

not_found do
    'Custom 404 error page'
end

error do
    'Custom error page'
end