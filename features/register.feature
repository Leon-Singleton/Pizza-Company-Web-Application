Feature: Register 
    Scenario: Register without inputs
        Given I am on the registration page
        When I click "Register"
        #Then I should NOT see "Please enter a different username"
        Then I should see "Please enter a password made of letters and numbers"
        Then I should see "Please enter a valid twitter account"
        Then I should see "Please enter a house name made of letters and numbers"
        Then I should see "Please enter a house number made up of numbers"
        Then I should see "Please enter a street name made up of letters"
        Then I should see "Please enter a postcode made of letters and numbers in a valid format"
        
    Scenario: Register with valid information
        Given I am on the registration page
        When I fill in the following:
            | username      | newuser   |
            | password      | password  |
            | twitter       | @neiltyson|
            | housename     | house     |
            | housenumber   | 10        |
            | street        | street    |
            | postcode      | S10 3AD   |
        When I click "Register"
        Then I should be on Menu page
        #Then I should see "Successful registeration!"
        #Then I should see "Welcome!"

# invalid input(s)
    Scenario: User try to register an new account, but the username has been used
        Given I am on the registration page
        When I fill in the following:
            | username      | sam       |
            | password      | password  |
            | twitter       | @testing  |
            | housename     | house     |
            | housenumber   | 10        |
            | street        | street    |
            | postcode      | S10 3AD   |
        When I click "Register"
        Then I should see "Please enter a different username"
        
    Scenario: Registration with invalid twitter id
        Given I am on the registration page
        When I fill in the following:
            | username      | newuser2  |
            | password      | password  |
            | twitter       | test      |
            | housename     | house     |
            | housenumber   | 10        |
            | street        | street    |
            | postcode      | S10 3AD   |
        When I click "Register"
        Then I should see "Please enter a valid twitter account"
        
#
    Scenario: Registration with invalid house name
        Given I am on the registration page
        When I fill in the following:
            | username      | newuser2  |
            | password      | password  |
            | twitter       | @testing  |
            | housename     |           |
            | housenumber   | 10        |
            | street        | street    |
            | postcode      | S10 3AD   |
        When I click "Register"
        Then I should see "Please enter a house name made of letters and numbers"
        
    Scenario: Registration with invalid house number
        Given I am on the registration page
        When I fill in the following:
            | username      | newuser2  |
            | password      | password  |
            | twitter       | @testing  |
            | housename     | house     |
            | housenumber   | number    |
            | street        | street    |
            | postcode      | S10 3AD   |
        When I click "Register"
        Then I should see "Please enter a house number made up of numbers"

#
    Scenario: Registration with invalid street
        Given I am on the registration page
        When I fill in the following:
            | username      | newuser2  |
            | password      | password  |
            | twitter       | @testing  |
            | housename     | house     |
            | housenumber   | 10        |
            | street        |           |
            | postcode      | S10 3AD   |
        When I click "Register"
        Then I should see "Please enter a street name made up of letters"
        
    Scenario: Registration with invalid postcode
        Given I am on the registration page
        When I fill in the following:
            | username      | newuser2  |
            | password      | password  |
            | twitter       | @testing  |
            | housename     | house     |
            | housenumber   | 10        |
            | street        | street    |
            | postcode      | 0         |
        When I click "Register"
        Then I should see "Please enter a postcode made of letters and numbers in a valid format"
 

