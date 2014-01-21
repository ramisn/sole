Feature: List of Store Orders
  In order to manage the discounts provided to large sellers to increase revenue
  As an admin, I want to be able to see the discounts
  
  Scenario: View the store orders
    Given I am a merchant
    And an open orders store exists with store: store "Store"
    And an open orders store exists with store: store "Store"
    And I am on the merchant store's orders page
    Then I should be on the merchant store's orders page
    Then I should see "Orders"
  
  Scenario: No store orders
    Given I am a merchant
    And I am on the merchant store's orders page
    Then I should see "There Are No Orders At This Time."
