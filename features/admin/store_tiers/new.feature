Feature: Add New Store Tiers
  In order to provide discounts to our largest sellers
  As an admin, I want to be able to add new store tiers
  
  Scenario: Add a new store tier
    Given I am an admin
    And I am on the admin store_tier new page
    When I fill in the following:
      | Name | Tier 1 |
      | Discount | 50 |
    And I press "Create"
    Then I should be on the admin store_tiers page
    And a store tier should exist with name: "Tier 1", discount: 50
    And I should see the following store tiers in "store_tiers":
      | Name | Discount |
      | Tier 1 | 50.0 |
