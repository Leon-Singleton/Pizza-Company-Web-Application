Feature: Staff
# Admin
    Scenario: Create a new admin account
        Given I am logged in as "admin"
        When I go to the create staff page
        When I fill in the following:
            | username      | newAdmin          |
            | password      | newAdmin          |
            | twitter       | @newAdmin         |
        When I select "Administrator" from "admin"
        When I press "Register"
        When I go to logout page
        # log into new account 
        When I go to login page
        When I fill in the following:
            | Username      | newAdmin          |
            | Password      | newAdmin          |
        When I press "Log In"
        Then I should be on admin page
        
    Scenario: Create a new orders account
        Given I am logged in as "admin"
        When I go to the create staff page
        When I fill in the following:
            | username      | newOrder          |
            | password      | newOrder          |
            | twitter       | @newOrder         |
        When I select "Restaurant" from "admin"
        When I press "Register"
        When I go to logout page
        # log into new account 
        When I go to login page
        When I fill in the following:
            | Username      | newOrder          |
            | Password      | newOrder          |
        When I press "Log In"
        Then I should be on orders page
    
    Scenario: Create a new marketing account
        Given I am logged in as "admin"
        When I go to the create staff page
        When I fill in the following:
            | username      | newMarket         |
            | password      | newMarket         |
            | twitter       | @newMarket        |
        When I select "Marketing" from "admin"
        When I press "Register"
        When I go to logout page
        # log into new account 
        When I go to login page
        When I fill in the following:
            | Username      | newMarket         |
            | Password      | newMarket         |
        When I press "Log In"
        Then I should be on marketing page
    
# Marketing
# Orders