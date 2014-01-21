Feature: Confirm a Refund was Paid
  In order to ensure that a refund was paid and not accidentally clicked
  As an admin, I want to confirm a refund was paid
  
  Scenario: Refund Part of an Order
    Given I am an admin
    And a credit owed order exists
    And I am on the refunds_payable admin payments page
    When I follow "Mark as Refunded"
    Then I should be on the admin order's new_refund payments page
    When I press "Mark as Refunded"
    Then the order "Order"'s payment_state should be "paid"
    And I should be on the refunds_payable admin payments page
    And I should see "Your refund was successfully logged"
    
  