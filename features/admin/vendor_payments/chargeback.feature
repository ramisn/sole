Feature: Chargeback a Merchant for a Payment Period
  In order to keep compliant with our terms of service with the merchants
  As an admin, I want to pay a merchant
  
  Scenario: Chargeback a Vendor
    Given I am an admin
    And there are vendor payments for many months
    And a vendor payment period: "Period" should exist with state: "chargeback_required"
    And I am on the admin vendor_payment_period's vendor_payment new page
    Then I should see "Confirm Chargeback of Vendor"
    And I should see "Amount: -$50.00"
    When I fill in the following:
      | Response Code | 1234 |
    And I press "Vendor was Chargebacked"
    Then I should be on the admin vendor_payment_periods page
    And vendor payment period "Period"'s state should be "paid"
  
