Feature: User Login Management, take 2
  In order to log in to the system,
  the user must provide their email address and password
  and click log on on the log in form.
  Scenario: Successful Login and Logout
    Given I am on the home page
    When I log in as a user
    Then I should be on the account page
    And I should see "Account Settings"
    And I should see "Sign out"
    When I follow "Sign out"
    Then I should be on the home page
    And I should see the button "log on"