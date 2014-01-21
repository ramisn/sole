Feature: Cancel Items in the Merchant Order
  In order to ensure that the system know when items that aren't being delivered
  As a merchant, I want to be able to select items of an order as being canceled
  
  Scenario: Cancel 1 item from the Merchant's Order
    Given I am a merchant
    And only an open order exists for store "Store"
    And I am on the merchant store's order's edit page
    Then I should be on the merchant store's order's edit page
    And I should see "cancel"
    When I follow "cancel"
    Then I should be on the merchant store's inventory_unit's confirm_cancel page
    And I should see "Confirm Cancellation of Item"
    When I press "Cancel Item"
    Then I should be on the merchant store's order's edit page
    And I should see "Item Canceled."
  
  Scenario: Cancel the remaining items from an order
    Given I am a merchant
    And only an open order exists for store "Store"
    And I am on the merchant store's orders page
    Then I should be on the merchant store's orders page
    When I follow "cancel remaining"
    Then I should be on the merchant store's order's confirm_cancel_remaining page
    And I should see "Items remaining to be canceled in the order"
    When I press "Cancel All Remaining Items"
    Then I should see "Remaining items canceled."
    And I should be on the merchant store's order's edit page
  
  Scenario: Admin force cancel's one item from the order
    Given I am an admin
    And a store: "Store" exists
    And only a shipped order exists for store "Store"
    And I am on the merchant store's order's edit page
    Then I should be on the merchant store's order's edit page
    And I should see "force cancel"
    When I follow "force cancel"
    Then I should be on the merchant store's inventory_unit's confirm_force_cancel page
    And I should see "Confirm Forced Cancellation of Shipped Item"
    When I press "Force Cancel Item"
    Then I should be on the merchant store's order's edit page
    And I should see "Item force canceled."
  
  Scenario: Admin force cancels a store's portion of an order from order list
    Given I am an admin
    And a store: "Store" exists
    And only a shipped order exists for store "Store"
    And I am on the merchant store's orders page with query string "complete_orders=1"
    When I follow "Complete Orders (1)"
    Then I should see "Force Cancel"
    When I follow "Force Cancel" within "#listing_orders"
    Then I should be on the merchant store's order's confirm_force_cancel page
    And I should see "Confirm Forced Cancellation of Order"
    When I press "Force Cancel Order"
    Then I should be on the merchant store's order's edit page
    And I should see "All items in store's order force canceled."
  
  Scenario: Admin force cancels a store's portion of an order from order edit
    Given I am an admin
    And a store: "Store" exists
    And only a shipped order exists for store "Store"
    And I am on the merchant store's order's edit page
    Then I should be on the merchant store's order's edit page
    When I follow "Force Cancel" within "#cancel-entire-order"
    Then I should be on the merchant store's order's confirm_force_cancel page
    And I should see "Confirm Forced Cancellation of Order"
    When I press "Force Cancel Order"
    Then I should be on the merchant store's order's edit page
    And I should see "All items in store's order force canceled."

