Feature: See List of Vendor Payments
  In order to know what vendors need to be paid
  As an admin, I want to see a list of all vendor payments
  
  Scenario: See All Vendor Payments
    Given I am an admin
    And there are vendor payments for many months
    And I am on the admin vendor payments page
    Then I should see the following vendor_payments in "vendor_payments":
      | Status | Merchant | Period | Paid At | Total |
      | Settled | Jarjar | Dec 2011 | 1/15/2012 | $20.00 | 
      | Settled | Nooka | Nov 2011 | 12/15/2011 | $350.00 |

