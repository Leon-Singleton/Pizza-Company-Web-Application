require 'erb'
require 'sinatra'
require 'sqlite3'
require 'geocoder'
set :bind, '0.0.0.0' # Only needed if you're running from Codio

include ERB::Util

enable :sessions
set :session_secret, 'super secret'

#as soon as this file is opened, the mene and user accounts databases are opened
before do
    @db = SQLite3::Database.new('useraccounts.sqlite')
    @db_menu = SQLite3::Database.new('menu.sqlite')
    
    #checks if a user has logged in and then sets the login state if one of the login sessions exists
    if (session[:logged_in_marketing] || session[:logged_in_admin] || session[:logged_in_orders] || session[:logged_in])
       @login = true
   end
end

enable :sessions
set :session_secret, 'super secret'

$pizzaid
$loginid
$statsid

#these global variables are set as regex (regular expressions) so that the format in which a user
#can enter details is restricted to that specific format only e.g. a postcode format    
VALID_TWITTER_REGEX = /(^|[^@\w])@(\w{1,15})\b/  
VALID_POSTCODE_REGEX = /^\s*((GIR\s*0AA)|((([A-PR-UWYZ][0-9]{1,2})|(([A-PR-UWYZ][A-HK-Y][0-9]{1,2})|(([A-PR-UWYZ][0-9][A-HJKSTUW])|([A-PR-UWYZ][A-HK-Y][0-9][ABEHMNPRVWXY]))))\s*[0-9][ABD-HJLNP-UW-Z]{2}))\s*$/          
VALID_NUMBER_REGEX = /\A[-+]?[0-9]*\.?[0-9]+\Z/

#this post method handles the instance a user tries to check their eligibility
#for delivery
post '/deliverycheck' do
                  
    @submitted =true
    @valid = false
    @sheffield=false
    @london=false
    
    #this select statement checks if the user has a postocde in the sheffield region beginning with an s
    sheffcheck = @db.get_first_value(
    'SELECT COUNT(*) FROM address WHERE id = ? AND postcode LIKE ?',
    [$loginid,'s%'])
    
    if sheffcheck > 0 then
        @sheffield=true
    end
    
    #this select statement checks if the user has a postocde in the central london region beginning with either
    #an ec or a w
    londoncheck = @db.get_first_value(
    'SELECT COUNT(*) FROM address WHERE id = ? AND postcode LIKE ?',
    [$loginid,'ec%'])
    
    londoncheck1 = @db.get_first_value(
    'SELECT COUNT(*) FROM address WHERE id = ? AND postcode LIKE ?',
    [$loginid,'w%'])
    
    if londoncheck > 0  || londoncheck1 > 0 then
        @london=true
        @valid =true
    end
            
    #these checks are here to make sure that the user's postcode is between s1 and s3 to identify them
    #as being in the central area of the sheffield region    
    count1 = @db.get_first_value(
    'SELECT COUNT(*) FROM address WHERE id = ? AND postcode LIKE ?',
    [$loginid,'s1%'])  
    count2 = @db.get_first_value(
    'SELECT COUNT(*) FROM address WHERE id = ? AND postcode LIKE ?',
    [$loginid,'s2%'])  
    count3 = @db.get_first_value(
    'SELECT COUNT(*) FROM address WHERE id = ? AND postcode LIKE ?',
    [$loginid,'s3%'])  
    
    if count1 > 0 || count2 > 0 || count3 > 0then
    @valid =true
    end 
    
    erb :interactivemenu   
end    
    
#home page
get '/home' do
    redirect '/'
    @submitted = false
    erb :index
end

#home page
get '/' do
    @submitted = false
    erb :index
end

#this is the interactive menu page
get '/Menu' do
    
   #this query is used to get all the information regarding menu items
   query = %{SELECT*FROM menu}
   @menu = @db_menu.execute query
    
   #this check is used to find the location of the user accessing the website,
   #if the user is identified as being from london as a result of the geocoder
   #gem then they will see pizzas that are exclusively available in london and those 
   #avaailable in both  areas
   city = request.location.city
       
   if (city == "London") then
        @city = 2
       else
        @city = 1
   end
       
   #if it is an admin that has logged into this page then they are given admin permissions
   if session[:logged_in_admin] then
       @perm = true
    
        #This check is used to make sure that the pizzas exclusive one particualr location are displayed 
        #correctly for the corresponding user
        location = @db.get_first_value(
        'SELECT Location FROM info WHERE id = ? ',
        [$loginid])
       
        @city = location
   end
       
       
   erb :interactivemenu
end

#This is the address of the contacts page
get '/contactus' do
    erb :contactus
end

#This is the address of the my details page where a customer can view or edit their details
get '/MyDetails' do

    #A user will be directed away from this page if the logged in session does not exist
    redirect '/' unless session[:logged_in]   
    
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
    @housename = @db.get_first_value(
    'SELECT house_name FROM address WHERE id = ? ',
    [$loginid])
    @housenumber = @db.get_first_value(
    'SELECT house_number FROM address WHERE id = ? ',
    [$loginid])
    @street = @db.get_first_value(
    'SELECT street FROM address WHERE id = ? ',
    [$loginid])
    @postcode = @db.get_first_value(
    'SELECT postcode FROM address WHERE id = ? ',
    [$loginid])  
    
  erb :editdetails
end

#this is the form submission which handles deletion of a users account
post '/deleteaccount' do
   @twitter = @db.get_first_value(
        'SELECT twitter FROM info WHERE id = ? ',
        [$loginid])  

    #the record corresponding to the users login id is deleted from both the address and 
    #info tables
    @db.execute(
      'DELETE FROM info WHERE id = ?',
      [$loginid])
    
    @db.execute(
      'DELETE FROM address WHERE id = ?',
      [$loginid])

    #all login sessions are then cleared and the user is re-directed to the home page
    session.clear
    redirect '/'
        
    erb :index   
end
    
#this post method handles the button instance of a user clicking the "update" button for a customers personal information   
post '/MyDetails' do
    
    #the values entered into the text fields are assigned to the following variables and are
    #stripped so that they do not contain any following spaces
    @submitted = true
    @username = params[:username].strip
    @password = params[:password].strip
    @twitter = params[:twitter].strip
    @housename = params[:housename].strip
    @housenumber = params[:housenumber].strip
    @street = params[:street].strip
    @postcode = params[:postcode].strip 
    
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
    
   
      
    #The following booleans are set as true if each field is not empty or does not contain a null value 
    #NOTICE: some information fields are also checked against a "REGEX" to make sure they are in the correct format
    @username_ok = !@username.nil? && @username != "" && @username_ok
    @password_ok = !@password.nil? && @password != ""
    @twitter_ok = !@twitter.nil? && @twitter != "" && @twitter_ok && @twitter =~ VALID_TWITTER_REGEX
    
    #This at unique check is only set as true if there is no record in both the info or address table matching any of the information already entered
    #to make sure that the user has actually entered details that are different from the ones before
    count = @db.get_first_value(
    'SELECT COUNT(*) FROM info WHERE username = ? AND password = ? AND twitter = ?',
    [@username, @password, @twitter])
    count1 = @db.get_first_value(
    'SELECT COUNT(*) FROM address WHERE twitter = ? AND house_name = ? AND house_number = ? AND street = ? AND postcode = ?',
    [@twitter, @housename, @housenumber, @street, @postcode])   
        if((count == 0) || (count1 ==0)) then
         @unique = true;
    end 
        
    #perform validation for non empty fields for address table 
    @housename_ok = !@housename.nil? && @housename != ""
    @housenumber_ok = !@housenumber.nil? && @housenumber != "" && @housenumber =~VALID_NUMBER_REGEX
    @street_ok = !@street.nil? && @street != ""
    @postcode_ok = !@postcode.nil? && @postcode != "" && @postcode =~ VALID_POSTCODE_REGEX
        
    #finally a boolean is set as true if all of the above variables are in a true state, this means that all fields 
    #were successfuly validated for
    @all_ok = @username_ok && @password_ok && @unique && @twitter_ok && @housename_ok && @housenumber_ok && @street_ok && @postcode_ok
    
    #once everything has been validated successfully the information in the text fields are submitted as an
    #updated record into the info and address tables, overwriting the previous records
    if @all_ok
        @db.execute(
        'UPDATE info SET username = ?, password = ?, twitter = ? WHERE id = ?',
        [@username, @password, @twitter, $loginid])
      
        @db.execute(
        'UPDATE address SET twitter = ?, house_name = ?, house_number = ?, street = ?, postcode = ? WHERE id = ?',
        [@twitter, @housename, @housenumber, @street, @postcode, $loginid]) 
     
     #follwoing ths successful update of a customers details, they are re-directed to the "interactive" menu page
     redirect '/Menu'
    end
    
    erb :editdetails
end

#This post submission handles the instance a user attempts to login to the website     
post '/login' do
        
    #the values entered into the text fields are assigned to the following variables and are
    #stripped so that they do not contain any following spacess
    @submitted = true
    @username = params[:username].strip
    @password = params[:password].strip
    
    #this validation checks that both the username and password entered actually match a record contained
    #in the info table of the useraccounts database    
    @result = @db.get_first_value(
    'SELECT DISTINCT password FROM info WHERE username = ? AND password = ?',
    [@username, @password])
    
    #once a users entered details have been validated the login id global variable is set as the unique record id 
    #corresponding to the logged in users details
    if params[:password] == @result
        $loginid = @db.get_first_value(
        'SELECT id FROM info WHERE username = ? AND password = ?',
        [@username, @password])
         
         #Also the admin id global variable is set as the admin id correspomnding to the logged in user to determine
         #their session priveleges
         $adminid = @db.get_first_value(
        'SELECT Admin FROM info WHERE username = ? AND password = ?',
        [@username, @password])
        session[:login_time] = Time.now
        
        #Depending on the type of user account logged in and their corresponiding admin value they are assigned a session
        #that corresponds to the logged in user account so that they can be given seperate priveleges and permissions
        #Also the user is redirected to the appropraite page depending on the account type
         if ($adminid ==0)    
            session[:logged_in] = true
            redirect '/Menu'
         end
         if ($adminid ==1)
             session[:logged_in_admin] = true
             redirect '/Admin'
         end
         if ($adminid ==2)
             session[:logged_in_orders] = true
             redirect '/Orders'
         end
         if ($adminid ==3)
             session[:logged_in_marketing] = true
             redirect '/Marketing'
         end
    else 
        #If a users details are incorrect it will inform the user that either the password or username are not valid
        @error = "Incorrect password or username"
    end
  erb :index
end

#This page handles the instance a user decides to log out of their account   
get '/logout' do
    # added to redirect users who haven't logged in back to the home page
    redirect '/' unless (session[:logged_in_marketing] || session[:logged_in_admin] || session[:logged_in_orders] || session[:logged_in])
    
    #clears all logged in sessions
    session.clear
    erb :logout
end

#This is the address of the register page for a new customer account
get '/register' do
    @submitted = false
    erb :register
end

#this post method handles the button instance of a user clicking the "register" button whilst on the customer registration page
post '/register' do
    @submitted = true
    
    #the values entered into the text fields are assigned to the following variables and are
    #stripped so that they do not contain any following spaces
    @username = params[:username].strip
    @password = params[:password].strip
    @twitter = params[:twitter].strip
    @housename = params[:housename].strip
    @housenumber = params[:housenumber].strip
    @street = params[:street].strip
    @postcode = params[:postcode].strip

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
      
    #The following booleans are set as true if each field is not empty or does not contain a null value
    #NOTICE: some information fields are also checked against a "REGEX" to make sure they are in the correct format
    @username_ok = !@username.nil? && @username != "" && @username_ok
    @password_ok = !@password.nil? && @password != "" 
    @twitter_ok = !@twitter.nil? && @twitter != "" && @twitter_ok && @twitter =~ VALID_TWITTER_REGEX
    
    #This unique check is only set as true if there is no record in the info table matching any of the information already entered
    #to make sure that the user has actually entered details that are different from the ones that may have been inserted previous
    count = @db.get_first_value(
        'SELECT COUNT(*) FROM info WHERE username = ? AND password = ?',
        [@username, @password])
    @unique = (count == 0)
        
    #perform validation for non empty fields for address table 
    @housename_ok = !@housename.nil? && @housename != ""
    @housenumber_ok = !@housenumber.nil? && @housenumber != "" && @housenumber =~VALID_NUMBER_REGEX
    @street_ok = !@street.nil? && @street != ""
    @postcode_ok = !@postcode.nil? && @postcode != "" && @postcode =~ VALID_POSTCODE_REGEX
    
    #finally a boolean is set as true if all of the above variables are in a true state, this means that all fields 
    #and conditions were successfuly validated for
    @all_ok = @username_ok && @password_ok && @unique && @twitter_ok && @housename_ok && @housenumber_ok && @street_ok && @postcode_ok
          
    #once everything has been validated successfully the information in the text fields are submitted as a new
    #inserted record into the info and address tables 
    if @all_ok
        #gets next available ID in the database that has not previously been username_ok
        #this id is then used as the id of the new record to be inserted
        id = @db.get_first_value 'SELECT MAX(id)+1 FROM info';
        #do the insert into the info table
        @db.execute(
        'INSERT INTO info VALUES (?, ?, ?, ?, ?, ?)',
        [id, @username, @password, @twitter, 0, 0])
        #do the insert into the address table
        @db.execute(
        'INSERT INTO address VALUES (?, ?, ?, ?, ?, ?)',
        [id, @twitter, @housename, @housenumber, @street, @postcode]) 
      
        #Once a user has registered they are then automatically logged in and so the global login id variable
        #is set as the corresponding id of the user's information record that has just registered
        $loginid = @db.get_first_value(
        'SELECT id FROM info WHERE username = ? AND password = ?',
        [@username, @password])
        
        #The newly registered user then recieves the customer log in session and is re-directed to the "Interactive" menu 
        #page which will allow them to make orders using their twitter account
               
        session[:logged_in] = true
        redirect '/Menu'
  end

  erb :register
end