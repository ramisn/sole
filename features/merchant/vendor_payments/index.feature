Feature: See List of Vendor Payments
  In order to know what vendors need to be paid
  As an admin, I want to see a list of all vendor payments
  
  Scenario: See All Vendor Payments
    Given I am a merchant
    And there are vendor payments for many months
    And I am a merchant of "Nooka"
    And I am on the merchant store's vendor_payments page
    Then I should see the following vendor_payments in "vendor_payments":
      | Status | Period | Paid At | Total |
      | Settled | Nov 2011 | 12/15/2011 | $350.00 |

