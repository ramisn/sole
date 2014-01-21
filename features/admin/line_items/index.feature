Feature: Line Item Drill-Down
  In order to allow the administrators to analyze the line items sold in the system
  As an admin, I want to be able to do a drill-down of the line items sold
  
  Scenario: View the line itmes from Completed Orders
    Given I am an admin
    And I am on the admin line items page
    Then I should see "Line Items"
    And I should see "Start"
    And I should see "Stop"
    And I should see "Download as CSV"