Feature: Destroy Store Tiers
  In order to manage the discounts provided to large sellers to increase revenue
  As an admin, I want to be able to destroy old store tiers
  
  ## Selenium has a bug finding the dialog
  #@javascript
  Scenario: Destroy a store tier
    Given I am an admin
    And a store tier: "Tier 1" exists with name: "Tier 1", discount: 50
    And I am on the admin store_tiers page
    When I press "Delete"
    #When I press "Delete"
    #And I confirm the popup
    Then I should be on the admin store_tiers page
    And a store tier should not exist with name: "Tier 1"
