Feature: Access
#usual situation
    Scenario: Admin access pages which should be accessible
        Given I am logged in as "admin"
        Then I should be able to visit admin page
        Then I should be able to visit marketing page
        Then I should be able to visit orders page
        Then I should be able to visit create staff page
        Then I should be able to visit my account page
        
    
    Scenario: Marketing access pages which should be accessible
        Given I am logged in as "marketing"
        Then I should be able to visit marketing page
        Then I should be able to visit my account page
        
    Scenario: Ordering access pages which should be accessible
        Given I am logged in as "orders"
        Then I should be able to visit orders page
        Then I should be able to visit my account page
        
    
    Scenario: Customer access pages which should be accessible
        Given I am logged in as "customer"
        Then I should be able to visit my details page
        
    
    Scenario: Guest access pages which should be accessible
        Given I am not logged in
        Then I should be able to visit login page
        Then I should be able to visit contactus page
        Then I should be able to visit menu page
        
        
        
#unusal situation
    Scenario: Customer access pages for staff
        Given I am logged in as "customer"
        When I go to admin page
        Then I should be redirected to home page
        When I go to marketing page
        Then I should be redirected to home page
        When I go to orders page
        Then I should be redirected to home page

# Guest tries to access pages for staff and member
    Scenario: Guest accesses pages which should NOT be accessible
        Given I am not logged in
        When I go to my details page
        Then I should be redirected to home page
        When I go to logout page
        Then I should be redirected to home page
        When I go to admin page
        Then I should be redirected to home page
        When I go to marketing page
        Then I should be redirected to home page
        When I go to orders page
        Then I should be redirected to home page
        