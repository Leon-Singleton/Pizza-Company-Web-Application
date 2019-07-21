Feature: Account management
# User account
    Scenario: User wants to delete his account
        Given I am on the login page
        When I fill in the following:
            | username      | newuser        |
            | password      | password           |
        When I press "Log In"
        Then I should be on menu page
        When I go to my details page        
        When I press "Delete My Account"
        Then I should be redirected to home page
        When I go to the login page
        When I fill in the following:
            | username      | newuser           |
            | password      | password           |
        When I press "Log In"
        Then I should see "Incorrect password"
       
    Scenario: User wants to change his account information
        Given I am logged in as "customer"
        Then I should be on menu page
        When I go to my details page        
        When I fill in the following:
            | username      | sam2           |
            | password      | sam2           |
        When I press "Update"
        When I log out
    # login using old info
        When I go to login page
        When I fill in the following:
            | username      | sam           |
            | password      | sam           |
        When I press "Log In"
        Then I should see "Incorrect password"
    # login using new info
        When I fill in the following:
            | username      | sam2           |
            | password      | sam2           |
        When I press "Log In"
        Then I should be on menu page
    # restore the account info
        When I go to my details page        
        When I fill in the following:
            | username      | sam           |
            | password      | sam           |
        When I press "Update"

# Staff account 
# testing for admin to manage accounts takes part in staff.feature
    Scenario: Admin wants to change his account information
        #account "admin1"
        Given I am logged in as "admin"
        When I go to my account page
        When I fill in the following:
            | username      | admin2           |
            | password      | admin2           |
        When I press "Update"
        When I log out
        When I go to login page
        When I fill in the following:
            | username      | admin1           |
            | password      | admin1           |
        When I press "Log In"
        Then I should see "Incorrect password"
        When I fill in the following:
            | username      | admin2           |
            | password      | admin2           |
        When I press "Log In"
        Then I should be on admin page
        When I go to my account page
        When I fill in the following:
            | username      | admin1           |
            | password      | admin1           |
        When I press "Update"