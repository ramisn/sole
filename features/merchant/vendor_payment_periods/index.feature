Feature: See List of Vendor Payment Periods
  In order to know what vendors need to be paid
  As an admin, I want to see a list of all vendor payments
  
  Scenario: See All Vendor Payment Periods
    Given I am a merchant
    And there are vendor payments for many months
    And I am a merchant of "Nooka"
    And I am on the merchant store's vendor_payment_periods page
    Then I should see the following vendor_payment_periods in "vendor_payment_periods":
      | Status | Month | # Orders | Total | Payment Amount |
      | Not Yet Due | Jan 2012 | 1 | $100.00 | $0.00 |
      | Payable | Dec 2011 | 2 | $200.00 | $0.00 |
      | Chargeback Required | Nov 2011 | 3 | $300.00 | $350.00 |

