Feature: Edit Page for Merchant Order
  In order to provide discounts to our largest sellers
  As an admin, I want to be able to add new store tiers
  
  Scenario: View the edit page for the merchant order
    Given I am a merchant
    And only an open order exists for store "Store"
    When I go to the merchant store's order's edit page
    Then I should be on the merchant store's order's edit page
    Then I should see "Order"
    And I should see the button "Mark as Shipped"
