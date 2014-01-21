Feature: List Payments that are refunds
  In order to track the amount of refunds given
  As an admin, I want to see the payments that have been refunded
  
  Scenario: There are refunded payments
    Given I am an admin
    And there are refunded payments
    And I am on the refunds_paid admin payments page
    Then I should be on the refunds_paid admin payments page
    Then I should see the following payments in "listing_orders":
      | Order Number | Refund |
      | R135 | $25.00 |
      | R246 | $15.00 |
      | R357 | $50.00 |
  
  Scenario: There are no refunded payment
    Given I am an admin
    And there are no refunded payments
    And I am on the refunds_paid admin payments page
    Then I should see "There are no refunded payments"
  