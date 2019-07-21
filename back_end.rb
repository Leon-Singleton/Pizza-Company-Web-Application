require 'sinatra' 
require 'googlecharts'
require 'gchart'

require_relative 'front_end'
require_relative 'twitter.rb'
#require 'sinatra/reloader'
set :bind,  '0.0.0.0'  # Only needed if you re running from Codio

include ERB::Util

#as soon as this file is opened, the mene and user accounts databases are opened
before do
    @db = SQLite3::Database.new('useraccounts.sqlite')
    @db_menu = SQLite3::Database.new('menu.sqlite')
    @db_stats = SQLite3::Database.new('statistics.sqlite')
end

enable :sessions
set :session_secret, 'super secret'

$pizzaid
$statsid

#this global variable is set as a regex (regular expression) so that the format in which a user
#can enter a twitter account is restricted to that specific format only 
VALID_TWITTER_REGEX = /(^|[^@\w])@(\w{1,15})\b/    

#This is the address of the my account page where a staff member can view or edit their details
get '/MyAccount' do
    
    #A user will be directed away from this page if one of the below logged in sessions does not exist
    redirect '/' unless (session[:logged_in_marketing] || session[:logged_in_admin] || session[:logged_in_orders])
    
    #these variables here are the information that is pulled from the database depending on the user that has logged in
    #then using these variables the information is set as the text of the information fields on the webpage
    @username = @db.get_first_value(
    'SELECT username FROM info WHERE id = ? ',
    [$loginid])      
    @password = @db.get_first_value(
    'SELECT password FROM info WHERE id = ? ',
    [$loginid])   
    @twitter = @db.get_first_value(
    'SELECT twitter FROM info WHERE id = ? ',
    [$loginid])
    
    erb :editdetailsstaff
end
#this post method handles the button instance of a user clicking the "update" button for a staffs personal information   
post '/MyAccount' do
    
    @submitted = true
    #the values entered into the text fields are assigned to the following variables and are
    #stripped so that they do not contain any following spaces
    @username = params[:username].strip
    @password = params[:password].strip
    @twitter = params[:twitter].strip
    
    #this check performs validation for same username already existing in the database
    uniname_check = @db.get_first_value( 
      'SELECT COUNT(*) FROM info WHERE username = ?',
      [@username])
    #if the count of returned usernames is 0 then the username does not already exist and so the state 
    #of a boolean is set to true
    if(uniname_check == 0 || @username) then
        @username_ok = true;
    end
      
    #similar to the validation above, a check is performed for the same twitter name alread existing
    unitwitter_check = @db.get_first_value( 
      'SELECT COUNT(*) FROM info WHERE twitter = ?',
      [@twitter])
    if(unitwitter_check == 0 || @twitter) then
        @twitter_ok = true;
    end     
    
    #The following booleans are set as true if each field is not empty and does not contain a null value
    #NOTICE: some information fields are also checked against a "REGEX" to make sure they are in the correct format 
    @username_ok = !@username.nil? && @username != "" && @username_ok
    @password_ok = !@password.nil? && @password != ""
    @twitter_ok = !@twitter.nil? && @twitter != "" && @twitter_ok && @twitter =~ VALID_TWITTER_REGEX  
        
    #finally a boolean is set as true if all of the above variables are in a true state, this means that all fields 
    #were successfuly validated for    
    @all_ok = @username_ok && @password_ok && @twitter_ok
     
    #once everything has been validated successfully the information in the text fields are submitted as an
    #updated record into the info table, overwriting the previous record
    if @all_ok
        @db.execute(
        'UPDATE info SET username = ?, password = ?, twitter = ? WHERE id = ?',
        [@username, @password, @twitter, $loginid])
       
        #Then depending on the account that had been edited and its account type the staff member is
        #re-directed to the appropriate staff area of the website
        if ($adminid ==1)
            redirect '/Admin'
        end
        if ($adminid ==2)
            redirect '/Orders'
        end
        if ($adminid ==3)
            redirect '/Marketing'
        end   
    end
      
   erb :editdetailsstaff
end

#marketing splash page
get '/Marketing' do
    #A user is directed away from this page unless the user is logged in as a marketing staff member or admin 
    #staff member
    redirect '/' unless (session[:logged_in_marketing] || session[:logged_in_admin])
    erb :marketingsplash
end

#test marketing campaigns page
get '/MarketingCampaign' do
    redirect '/' unless (session[:logged_in_marketing] || session[:logged_in_admin])
    t = TwitterConnect.new()
    erb :marketingcampaign
end

#admin splash page
get '/Admin' do
    #A user is directed away from this page unless the user is logged in as an admin staff member
    redirect '/' unless session[:logged_in_admin]

    @year = Time.now.strftime("%Y").to_i
    @month = Time.now.strftime("%m").to_i
    @day = Time.now.strftime("%d").to_i
    @sum = @day + @month
    #Statistics

    t = TwitterConnect.new()
    @followers = t.get_followers()
    #takes the number of unique users
    @users = @db.get_first_value( 
      'SELECT COUNT(*) FROM info WHERE Location = 0')
    @id = @db_stats.get_first_value 'SELECT MAX(id) FROM stats';
    #identifies the last change made to the number of unique users
    @lastUsers = @db_stats.get_first_value(
        'SELECT UniqueUsers FROM stats WHERE id = ?',[@id])
    #identifies the last change made to the number of followers
    @lastFollowers = @db_stats.get_first_value(
        'SELECT TwitterFollowers FROM stats WHERE id = ?', [@id])
    
    #if any new users or followers have been added or removed
    if @users != @lastUsers || @followers  != @lastFollowers
        @newId = @id +1
        @db_stats.execute(
                'INSERT INTO stats VALUES(?, ?, ?, ?, ?, ?)',
                [@newId, @year, @month, @day, @users, @followers])
        redirect '/Admin'
    end
    
    $statsid = params[:statsid].to_i
    if($statsid == 0) then
     @allUsers = @db_stats.execute(
        'SELECT*FROM stats ORDER BY id DESC')
        
    elsif $statsid == 1 then
        @allUsers = @db_stats.execute(
        'SELECT*FROM stats WHERE day = ? ORDER BY id DESC', [@day])
         
    elsif $statsid == 2 then
          @allUsers = @db_stats.execute(
        'SELECT*FROM stats WHERE month = ?', [@month])
         
    else
          @allUsers = @db_stats.execute(
        'SELECT*FROM stats WHERE year = ?', [@year])

    end
    
    #creating two arrays of info from the database
    #to turn into a graph
  
    userArray = Array.new
    followersArray = Array.new
    max=0 
        
    @userDatabase = @db_stats.execute(
        'SELECT UniqueUsers FROM stats')
    @userDatabase.each do |users|
        userArray.push(users[0].to_i)
        if(users[0].to_i > max)
            max = users[0].to_i
        end
    end
        
    @followersDatabase = @db_stats.execute(
        'SELECT TwitterFollowers FROM stats')
    @followersDatabase.each do |followers|
        followersArray.push(followers[0].to_i)
        if (followers[0].to_i > max)
            max = followers[0].to_i
        end
    end
    #max will offer the range of the y axis
     @chart = Gchart.line(
            :data => [userArray, followersArray], 
            :axis_with_labels => 'y',
            :axis_range => [[0, max, 1]],
            :title => 'Statistics', 
            :legend => ['Users','Followers'], 
            :bg => {:color => '337ab7', :type => 'gradient'}, 
            :bar_colors => 'ff0000,00ff00')
    erb :adminsplash
end

#orders splash page
get '/Orders' do
     #A user is directed away from this page unless the user is logged in as an admin staff member or 
     #orders staff member
    redirect '/' unless (session[:logged_in_orders] || session[:logged_in_admin])
    
    t = TwitterConnect.new()
    t.find_tweets()
    t.follow()
    @usernames = t.get_usernames()
    @text = t.get_tweet_text()
    #variables storing the different message types an orders staff member can send back to the customer
    @confirmation = 'Your order has been received. Please wait for confirmation.'
    @accept = 'Your order has been accepted. '
    @delivery = 'We will deliver your order in 20 min'
    @collect = 'Please collect your order in 30 min'
    @decline = 'Your tweet is unreadable. Please resubmit.'
    
    erb :orderssplash
end

#the address path of the page where an admin can create a new staff account
get '/CreateStaff' do
    redirect '/' unless session[:logged_in_admin]
    erb :newstaffaccount
end


post '/CreateStaff' do
  @submitted = true
    
  #the values entered into the text fields are assigned to the following variables and are
  #stripped so that they do not contain any following spaces
  @username = params[:username].strip
  @password = params[:password].strip
  @twitter = params[:twitter].strip
  @admin = params[:admin].strip
  @location = params[:location].strip
    
  #this check performs validation for same username already existing in the database
    uniname_check = @db.get_first_value( 
        'SELECT COUNT(*) FROM info WHERE username = ?',
        [@username])
    #if the count of returned usernames is 0 then the username does not already exist and so the state 
    #of a boolean is set to true
    if(uniname_check == 0) then
        @username_ok = true;
    end
   
  #similar to the validation above, a check is performed for the same twitter name alread existing
  unitwitter_check = @db.get_first_value( 
      'SELECT COUNT(*) FROM info WHERE twitter = ?',
      [@twitter])
  if(unitwitter_check == 0) then
      @twitter_ok = true;
  end           
      
  #The following booleans are set as true if each field is not empty and does not contain a null value
  #NOTICE: some information fields are also checked against a "REGEX" to make sure they are in the correct format
  @username_ok = !@username.nil? && @username != "" && @username_ok
  @password_ok = !@password.nil? && @password != "" 
  @twitter_ok = !@twitter.nil? && @twitter != "" && @twitter_ok && @twitter =~ VALID_TWITTER_REGEX
  
  #This unique check is only set as true if there is no record in the info table matching any of the information already entered
  #that may have been entered previoously so that duplicate accounts cannot be created
  count = @db.get_first_value(
    'SELECT COUNT(*) FROM info WHERE username = ? AND password = ?',
    [@username, @password])
  @unique = (count == 0)
      
  #finally a boolean is set as true if all of the above variables are in a true state, this means that all fields 
  #and conditions were successfuly validated for
  @all_ok = @username_ok && @password_ok && @twitter_ok
  
  #add data to the database for info table
  if @all_ok
    #get next available ID
    id = @db.get_first_value 'SELECT MAX(id)+1 FROM info';
      
    #do the insert
    @db.execute(
    'INSERT INTO info VALUES (?, ?, ?, ?, ?, ?)',
    [id, @username, @password, @twitter,@admin,@location]) 
    
    #redirects the admin staff member back to the admin home page
    session[:logged_in_admin] = true    
    redirect '/Admin'   
  end
  erb :newstaffaccount    
end
      
#this post method handles the button instance of a user clicking the delete button for a menu item        
post '/deletepizza' do
      
    #the record corresponding to the users login id is deleted from both the address and 
    #info tables
    @db_menu.execute(
      'DELETE FROM menu WHERE id = ?',
      [$pizzaid])
        
    redirect '/Menu'
end
    
#This is the address of the page where an admin user can edit the menu
get '/editMenu' do
    
   #all users will be directed away from this page unless they are logged in as an admin user
   redirect '/' unless session[:logged_in_admin]

   #these variables here are the information that is pulled from the database correlating to a menu item
   #then using these variables the information regarding that menu item is set as the text of the information 
   #fields on the webpage
   $pizzaid = params[:pizzaid]
   @name = @db_menu.get_first_value( 
       'SELECT name FROM menu WHERE id = ? ',
    [$pizzaid])
   @twitter = @db_menu.get_first_value(
       'SELECT twitter_code FROM menu WHERE id = ? ',
    [$pizzaid])
    @description = @db_menu.get_first_value(
        'SELECT description FROM menu WHERE id = ? ',
    [$pizzaid])
    @price = @db_menu.get_first_value(
        'SELECT price FROM menu WHERE id = ? ',
    [$pizzaid])
    @location = @db_menu.get_first_value(
        'SELECT location FROM menu WHERE id = ? ',
    [$pizzaid])
    erb :editMenu
end

#This is the code submitted when a user does a form submission on the edit menu webpage
post '/editMenu' do
    @submitted = true
    #the values entered into the text fields are assigned to the following variables and are
    #stripped so that they do not contain any following spacess
    $pizzaid = params[:pizzaid]
    @name = params[:name].strip
    @twitter = params[:twitter].strip
    @description = params[:description].strip
    @price = params[:price].strip
    @location = params[:location].strip
    
    #this check performs validation for same username already existing in the database
    uniname_check = @db_menu.get_first_value( 
      'SELECT COUNT(*) FROM menu WHERE name = ?',
      [@name])
    #if the count of returned usernames is 0 then the username does not already exist and so the state 
    #of a boolean is set to true
    if(uniname_check == 0 || @name) then
        @name_ok = true;
    end
      
    #similar to the validation above, a check is performed for the same twitter name alread existing
    unitwitter_check = @db_menu.get_first_value( 
      'SELECT COUNT(*) FROM menu WHERE twitter_code = ?',
      [@twitter])
    if(unitwitter_check == 0 || @twitter) then
        @twitter_ok = true;
    end  
        
    #perform validation for valid new location code that is assigned to the menu item
    if (Integer(@location) == 2 && Integer(@location) == 3 )then
        @location_ok = true
        else
        @location_ok = false
    end
      
    #The following booleans are set as true if each field is not empty and does not contain a null value and also if the 
    #new menu item is completely unique to any others that may already exist in the database
    @name_ok = !@name.nil? && @name != "" && @name_ok
    @twitter_ok = !@twitter.nil? && @twitter != "" && @twitter_ok 
    count = @db_menu.get_first_value(
    'SELECT COUNT(*) FROM menu WHERE name = ? AND twitter_code = ?',
    [@name, @twitter])
    @unique = (count == 1) 
    @description_ok = !@description.nil? && @description != ""
    @price_ok = !@price.nil? && @price != ""
    @location_ok = !@location.nil? && @location != "" && @location
        
    #finally a boolean is set as true if all of the above variables are in a true state, this means that all fields 
    #successfuly validated for
    @all_ok = @name_ok && @twitter_ok && @description_ok && @price_ok && @location_ok && @unique
    
    #once everything has been validated successfully the information in the text fields are submitted as an
    #updated record into the menu table, overwriting the previous record
    if @all_ok
        @db_menu.execute(
        'UPDATE menu SET name = ?, twitter_code = ?, description = ?, price = ?, location = ? WHERE id = ?',
        [@name, @twitter, @description, @price, @location, $pizzaid])
     
     #following the insert the user is redirected the menu page
     redirect '/Menu'
    end
    
    erb :editMenu
end

#this is the address path of the add pizza page
get '/AddPizza' do
        
    #all users will be directed away from this page unless they are logged in as an admin user    
    redirect '/' unless session[:logged_in_admin]
    erb :addpizza
end

post '/AddPizza' do
  @submitted = true
        
  #the values entered into the text fields are assigned to the following variables and are
  #stripped so that they do not contain any following spaces
  @name = params[:name].strip
  @twitter = params[:twitter].strip
  @description = params[:description].strip
  @price = params[:price].strip
  @location = params[:location].strip
    
  #this check performs validation for same pizz name already existing in the database
  name_check = @db_menu.get_first_value( 
      'SELECT COUNT(*) FROM menu WHERE name = ?',
      [@name])
  #if the count of returned usernames is 0 then the pizza name does not already exist and so the state 
  #of a boolean is set to true
  if(name_check == 0) then
      @name_ok = true;
  end
   
 #similar to the validation above, a check is performed for the same twitter hashtag identifier alread existing
  twitter_check = @db_menu.get_first_value( 
      'SELECT COUNT(*) FROM menu WHERE twitter_code = ?',
      [@twitter])
  if(twitter_check == 0) then
      @twitter_ok = true;
  end     
      
  # perform validation for location code
  if(@location != "" && !@location.nil?) then
  if(Integer(@location) >= 2 && Integer(@location) <= 3) then
      @location_ok = true
  end
  end
      
  #The following booleans are set as true if each field is not empty and does not contain a null value
  @name_ok = !@name.nil? && @name != "" && @name_ok
  @twitter_ok = !@twitter.nil? && @twitter != "" && @twitter_ok 
  @price_ok = !@price.nil? && @price != ""
  @location_ok = !@location.nil? && @location != "" && @location_ok
      
  #This unique check is only set as true if there is no record in the menu table matching any of the information already entered
  #to make sure that the user has actually entered details that are different from the ones that may have been inserted previous   
  count = @db_menu.get_first_value(
    'SELECT COUNT(*) FROM menu WHERE name = ? AND twitter_code = ?',
    [@name, @twitter])
  @unique = (count == 0)
      
  #finally a boolean is set as true if all of the above variables are in a true state, this means that all fields 
  #and conditions were successfuly validated for    
  @all_ok = @name_ok && @twitter_ok && @unique && @location_ok && @price_ok
      
  # add data to the database for info table
  if @all_ok
    #get next available ID
    id = @db_menu.get_first_value 'SELECT MAX(id)+1 FROM menu'
      
    #do the insert
    @db_menu.execute(
    'INSERT INTO menu VALUES (?, ?, ?, ?, ?, ?)',
        [id, @name, @twitter, @description, @price, @location])   
    session[:logged_in_admin] = true    
    redirect '/Admin'   
  end
  erb :addpizza  
end
