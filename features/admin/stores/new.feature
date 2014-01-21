Feature: Add New Stores
  In order to generate revenue by having merchants on the site
  As an admin, I want to be able to add new stores
  
  Scenario: Adding a new store with a Store Tier
    Given I am an admin
    And a store tier: "Tier 1" exists with name: "Tier 1"
    And a user exists with email: "jaja@example.com"
    When I go to the admin store's new page
    Then I should be on the admin store's new page
    When I fill in the following:
      | Store Name | Jaja Boo |
      | Company Overview | There we go again! |
      | Store Manager | jaja@example.com |
      | store_brands_list | Jaja Hungry |
      | USA ePay Customer Number | 1 |
    And I select "Tier 1" from "Store Tier"
    And I press "Create"
    Then I should be on the admin stores page
    And a store should exist with store_tier: store_tier "Tier 1", usa_epay_customer_number: 1
