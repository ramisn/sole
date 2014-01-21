Feature: Create a new Product
  In order to have products in the marketplace
  As a merchant, I want to be able to create a product

  Scenario: Create a Product
    Given I am a merchant
    And I am on the merchant store's products page
    Then I should see "add new product"
    Given I create a new product "test"
#    Then I should be on the merchant store's product's variant page
