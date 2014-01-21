Feature: Edit Stores
  In order to manage the discounts generate revenue by having merchants on the site
  As an admin, I want to be able to add edit existing stores
  
  Scenario: Changing the USA Epay Customer Number
    Given I am an admin
    And a store: "Store" exists with usa_epay_customer_number: 1
    And I am on the admin store edit page
    When I fill in "USA ePay Customer Number" with "5"
    And I press "Update"
    Then I should be on the admin stores page
    And I should see "Store has been successfully updated!"
  
  Scenario: Changing the Store Tier of an existing Store
    Given I am an admin
    And a store tier: "Tier 1" exists with name: "Tier 1"
    And a store tier: "Tier 2" exists with name: "Tier 2"
    And a store: "Store" exists with store_tier: store tier "Tier 1"
    And I am on the admin store edit page
    When I select "Tier 2" from "Store Tier"
    And I press "Update"
    Then I should be on the admin stores page
    And store tier "Tier 2" should be store "Store"'s store_tier
  
  Scenario: Removing the Store Tier of an existing Store
    Given I am an admin
    And a store tier: "Tier 1" exists with name: "Tier 1"
    And a store: "Store" exists with store_tier: store tier "Tier 1"
    And I am on the admin store edit page
    When I select "" from "Store Tier"
    And I press "Update"
    Then I should be on the admin stores page
    And the store "Store"'s store_tier should be nil
  
  Scenario: Adding a Store Tier to an existing Store without one
    Given I am an admin
    And a store tier: "Tier 1" exists with name: "Tier 1"
    And a store: "Store" exists
    And I am on the admin store edit page
    When I select "Tier 1" from "Store Tier"
    And I press "Update"
    Then I should be on the admin stores page
    And store_tier "Tier 1" should be store "Store"'s store_tier
