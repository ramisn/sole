Feature: List unpaid refunds to customers
  In order to ensure that customers are happy and are given prompt payment of their refunds
  As an admin, I want to see a list of all orders that need to be refunded money
  
  Scenario: See orders needing refund
    Given I am an admin
    And I have orders that are credit owed
    And I am on the refunds_payable admin payments page
    Then I should see the following payments in "listing_orders":
      | Order | Total | Paid | Owed |
      | R123 | $100.00 | $150.00 | $50.00 |
      | R234 | $0.00 | $25.00 | $25.00 |
      | R345 | $25.00 | $45.00 | $20.00 |
      | R456 | $10.00 | $15.00 | $5.00 |
  
  Scenario: There are no refunds
    Given I am an admin
    And I have no orders that are credit owed
    And I am on the refunds_payable admin payments page
    Then I should see "There are currently no orders that need refunds"
  