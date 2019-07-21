module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /tweet/
        '/intent/tweet'
            
    #for general
    when /home/
        '/'
        
    when /home\s?page/
        '/'

    when /contactus/
        '/contactus'

    when /registration/
        '/register'
    
    when /login/
        '/'
                
    when /menu/
        '/Menu'
        
    when /Menu/
        '/Menu'
        
    #for member
    when /logout/
        '/logout'
    
    when /my\s?detail\s?/
        '/MyDetails'
        
    when /detail/
        '/MyDetails'
    
    when /my\s?account/
        '/MyAccount'
        
    #for orders
    when /orders/
        '/Orders'
        
    #for marketing
    when /marketing/
        '/Marketing'
        
    #for admin
    when /admin/
        '/Admin'
    
    when /create staff/
        '/CreateStaff'
        
    else
        raise "Can't find mapping from \#{page_name}\ to a path\n"
        "Now go and find a mapping in #{__FILE__}"
    end
  end 
end

World(NavigationHelpers)