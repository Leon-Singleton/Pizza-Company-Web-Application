require 'cucumber'
require 'capybara'
require 'rspec'

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

# visit page
Given /^I am on the (.+) page$/ do |page_name|
  visit path_to(page_name)
end

# login session
Given /^I am logged in as "([^\"]*)"$/ do |access|
    case access
        when "admin"
            user = "admin1"
            password = "admin1"
        when "marketing"
            user = "marketing"
            password = "marketing"
        when "orders"
            user = "orders"
            password = "orders"
        when "customer"
            user = "sam"
            password = "sam"
    end
    step "I am on the login page"
    step "I fill in \"username\" with \"#{user}\""
    step "I fill in \"password\" with \"#{password}\""
    step "I press \"Log In\""
    case access
        when "admin"
            step "I should be on the admin page"
        when "marketing"
            step "I should be on the marketing page"
        when "orders"
            step "I should be on the orders page"
        when "customer"
            step "I should be on the menu page"
    end
end

# NOT logged in 
Given /^I am not logged in$/ do
end

When /^I log out$/ do
    visit '/logout'
end

# visit page
When /^I go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

# press a button
When /^I press "([^\"]*)"(?: within "([^\"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(button)
  end
end

# click a button
When /^I click "([^\"]*)"(?: within "([^\"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(button)
  end
end

# click on id
When /^I click #([^\"]*)?$/ do |id|
    page.find("##{id}").click
end

# fill a field
When /^I fill in "([^\"]*)" with "([^\"]*)"(?: within "([^\"]*)")?$/ do |field, value, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end
   
# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
When /^I fill in the following(?: within "([^\"]*)")?:$/ do |selector, fields|
  with_scope(selector) do
    fields.rows_hash.each do |name, value|
      step "I fill in \"#{name}\" with \"#{value}\""
    end
  end
end

# select from dropdown menu
When /^I select "([^\"]*)" from "([^\"]*)"(?: within "([^\"]*)")?$/ do | value, field, selector|
  with_scope(selector) do
    find(:option, value, field).select_option
  end
end

# should see something 
Then /^I should see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end

# should NOT see something 
Then /^I should NOT see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_content(text)
    else
      assert page.has_no_content?(text)
    end
  end
end

# on specific page
Then /^I should be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end    

# on specific page
Then /^I should be redirected to (.+)$/ do |page_name|
    step "I should be on #{page_name}"
end

Then /^I should be able to visit (.+)$/ do |page_name|
    step "I go to #{page_name}"
    step "I should be on #{page_name}"
end