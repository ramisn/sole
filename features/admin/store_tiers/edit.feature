Feature: Edit Existing Store Tiers
  In order to provide discounts to our largest sellers
  As an admin, I want to be able to add new store tiers
  
  Scenario: Edit an existing store tier
    Given I am an admin
    And a store tier: "Tier 1" exists with name: "Tier 1", discount: 50
    And I am on the admin store_tier edit page
    When I fill in the following:
      | Discount | 25 |
    And I press "Update"
    Then I should be on the admin store_tiers page
    And store tier should exist with name: "Tier 1", discount: 25
    And I should see the following store tiers in "store_tiers":
      | Name | Discount |
      | Tier 1 | 25.0 |
