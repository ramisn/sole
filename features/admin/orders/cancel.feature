Feature: Cancelling Orders in Admin Area
  In order to ensure that customers are kept happy by not being charged for what they didn't buy
  As an admin, I want to be able to cancel orders in the admin area
  
  Scenario: Force cancel an entire order
    Given I am an admin
    And a store: "Store" exists
    And only a shipped order exists for store "Store"
    And I am on the admin orders page
    When I follow "force cancel"
    Then I should be on the admin order's confirm_force_cancel page
    And I should see "Confirm Forced Cancellation of Entire Order"
    When I press "Force Cancel Entire Order"
    Then I should see "You have successfully forced the cancelation of the entire order."
    And I should be on the admin orders page
  