Feature: Login 
# Valid login    
    Scenario: User enters correct password and user is ADMIN
        Given I am on the login page
        When I fill in the following:
            | username      | admin1        |
            | password      | admin1        |
        When I press "Log In"
        Then I should be on admin page 
        When I go to logout page
        Then I should be on logout page
        Then I should see "Logged out"
        
    Scenario: User enters correct password and user is MARKETING staff
        Given I am on the login page
        When I fill in the following:
            | username      | marketing     |
            | password      | marketing     |
        When I press "Log In"
        Then I should be on marketing page
    
    Scenario: User enters correct password and user is ORDERS staff
        Given I am on the login page
        When I fill in the following:
            | username      | orders        |
            | password      | orders        |
        When I press "Log In"
        Then I should be on orders page
    
    Scenario: User enters correct password and user is CUSTOMER
        Given I am on the login page
        When I fill in the following:
            | username      | sam           |
            | password      | sam           |
        When I press "Log In"
        Then I should be on Menu page
        #Then I should be on page for customer
        
# Invalid login    
    Scenario: User enters incorrect password
        Given I am on the login page
        When I fill in the following:
            | username      | sam           |
            | password      | hey           |
        When I press "Log In"
        Then I should see "Incorrect password"
        
    Scenario: User enters non-exist username
        Given I am on the login page
        When I fill in the following:
            | username      | notExist      |
            | password      | notExist      |
        When I press "Log In"
        Then I should see "Incorrect password"
        #Then I should see "error message"
        
# logout
# errors need to be fixed
    Scenario: logout test for all type of account
        # admin
        Given I am logged in as "admin"
        When I go to logout page
        Then I should be on logout page
        Then I should see "Logged out"
        When I go to admin page
        Then I should be redirected to home page
        # marketing
        Given I am logged in as "marketing"
        When I go to logout page
        Then I should see "Logged out"
        When I go to marketing page
        Then I should be redirected to home page
        # orders
        Given I am logged in as "orders"
        When I go to logout page
        Then I should see "Logged out"
        When I go to orders page
        Then I should be redirected to home page
        # customer
        Given I am logged in as "customer"
        When I go to logout page
        Then I should see "Logged out"
        When I go to my details page
        Then I should be redirected to home page
        
        
        
       
      
  