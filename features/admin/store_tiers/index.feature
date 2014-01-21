Feature: List of Store Tiers
  In order to manage the discounts provided to large sellers to increase revenue
  As an admin, I want to be able to see the discounts
  
  Scenario: View the store tiers
    Given I am an admin
    And a store tier: "Tier 1" exists with name: "Tier 1", discount: 50
    And a store tier: "Tier 2" exists with name: "Tier 2", discount: 25
    And I am on the admin store_tiers page
    Then I should see the following store tiers in "store_tiers":
      | Name | Discount |
      | Tier 1 | 50.0 |
      | Tier 2 | 25.0 |
  
  Scenario: No store tiers
    Given I am an admin
    And I am on the admin store_tiers page
    Then I should see "There are currently no store tiers."
