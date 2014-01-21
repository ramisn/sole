Feature: See List of Vendor Payment Periods
  In order to know what vendors need to be paid
  As an admin, I want to see a list of all vendor payments
  
  Scenario: See All Vendor Payment Periods
    Given I am an admin
    And there are vendor payments for many months
    And I am on the admin vendor_payment_periods page
    Then I should see the following vendor_payment_periods in "vendor_payment_periods":
      | Status | Merchant | Month | # Orders | Total | Payment Amount |
      | Not Yet Due | Nooka | Jan 2012 | 1 | $100.00 | $0.00 |
      | Paid | Jarjar | Dec 2011 | 1 | $20.00 | $20.00 |
      | Payable | Nooka | Dec 2011 | 2 | $200.00 | $0.00 |
      | Payable | Dunkel | Dec 2011 | 1 | $50.00 | $0.00 |
      | Chargeback Required | Nooka | Nov 2011 | 3 | $300.00 | $350.00 |
  
  Scenario: See Payable Vendor Payment Periods
    Given I am an admin
    And there are vendor payments for many months
    And I am on the admin vendor_payment_periods page
    When I select "Payable" from "state"
    And I press "Filter"
    Then I should be on the admin vendor_payment_periods page
    Then I should see the following vendor_payment_periods in "vendor_payment_periods":
      | Status | Merchant | Month | # Orders | Total | Payment Amount |
      | Payable | Nooka | Dec 2011 | 2 | $200.00 | $0.00 |
      | Payable | Dunkel | Dec 2011 | 1 | $50.00 | $0.00 |
  
  Scenario: See Vendor Payment Periods for a Specific Month
    Given I am an admin
    And there are vendor payments for many months
    And I am on the admin vendor_payment_periods page
    When I select "Nov 2011" from "Start month"
    And I select "Nov 2011" from "End month"
    And I press "Filter"
    Then I should be on the admin vendor_payment_periods page
    Then I should see the following vendor_payment_periods in "vendor_payment_periods":
      | Status | Merchant | Month | # Orders | Total | Payment Amount |
      | Chargeback Required | Nooka | Nov 2011 | 3 | $300.00 | $350.00 |
  
  Scenario: See Paid Payment Periods for a Specific Month
    Given I am an admin
    And there are vendor payments for many months
    And I am on the admin vendor_payment_periods page
    When I select "Dec 2011" from "Start month"
    And I select "Dec 2011" from "End month"
    And I select "Paid" from "state"
    And I press "Filter"
    Then I should be on the admin vendor_payment_periods page
    Then I should see the following vendor_payment_periods in "vendor_payment_periods":
      | Status | Merchant | Month | # Orders | Total | Payment Amount |
      | Paid | Jarjar | Dec 2011 | 1 | $20.00 | $20.00 |

