Feature: Viewing the Line Items attached to a Merchant's Payment
  In order to allow merchants to know what they're being paid for
  As a merchant, I want to see the aggregate details on the orders I shipped
  
  Scenario: View a Payment's Details
    Given I am a merchant
    And store "Store" has payments in the system
    And I am on the merchant store's vendor_payment_period's page
    Then I should see "Nov 2011"
    And I should see "Total Reimbursement Owed by Soletron: $44.58"
    And I should see the following line_items in "line_items":
      | Order Date | Order # | SKU | Name | Quantity | Price | Merchant % | Merchant Amount |
      | 11/1/2011 | 123 | 1 | Hi Heels | 1 | $20.00 | 60.0% | $12.00 |
      | 11/16/2011 | 234 | 1 | Hi Heels | 2 | $20.00 | 60.0% | $24.00 |
      | # Line Items | # Orders |  |  | Quantity Sold | Average Price | Merchant % | Merchant Payment |
      | 2 | 2 | | | 3 | $20.00 | 60.0% | $36.00 |
    And I should see the following adjustments in "shipping":
      | Order Date | Order # | # Items | Total Shipping |
      | 11/1/2011 | 123 | 1 | $4.99 |
      | 11/16/2011 | 234 | 2 | $5.99 |
      | # Shipping Charges | | Quantity Shipped | Total Shipping Charges |
      | 2 | | 3 | $10.98 |
    And I should see the following promotion_credits in "coupons":
      | Order Date | Order # | Coupon Value |
      | 11/16/2011 | 234 | -$2.40 |
      | # Coupons Applied | | Total Coupon Value |
      | 1 | | -$2.40 |
  
  Scenario: View a Payment's Line Items CSV file
    Given I am a merchant
    And store "Store" has payments in the system
    And I am on the merchant store's vendor_payment_period's page
    Then I should see "Line Items CSV"
    When I follow "Line Items CSV"
    Then I should see the csv table:
      | Order Date | Order # | SKU | Name | Quantity | Price | Merchant % | Merchant Amount |
      | 11/1/2011 | 123 | 1 | Hi Heels | 1 | $20.00 | 60.0% | $12.00 |
      | 11/16/2011 | 234 | 1 | Hi Heels | 2 | $20.00 | 60.0% | $24.00 |
  
  Scenario: View a Payment's Shipments CSV file
    Given I am a merchant
    And store "Store" has payments in the system
    And I am on the merchant store's vendor_payment_period's page
    Then I should see "Shipping CSV"
    When I follow "Shipping CSV"
    Then I should see the csv table:
      | Order Date | Order # | # Items | Total Shipping |
      | 11/1/2011 | 123 | 1 | $4.99 |
      | 11/16/2011 | 234 | 2 | $5.99 |
  
  Scenario: View a Payment's Coupons CSV file
    Given I am a merchant
    And store "Store" has payments in the system
    And I am on the merchant store's vendor_payment_period's page
    When I follow "Coupons CSV"
    Then I should see the csv table:
      | Order Date | Order # | Coupon Value |
      | 11/16/2011 | 234 | -$2.40 |
  
  Scenario: View a Payment's Details as an Admin
    Given I am an admin
    And an open orders store exists
    And store "Store" has payments in the system
    And I am on the merchant store's vendor_payment_period's page
    When I follow "View All Vendor Payment Periods In Admin"
    Then I am on the admin vendor_payment_periods page
  
  