Then /^I should see the following #{capture_model}s? in "([\w\-]+)":$/ do |model, table_name, expected_table|
  expected_table.diff!(table(tableish("table##{table_name} tr", 'td,th')))
end

Then /^I should see the csv table:$/ do |table|
  actual_table = CSV.parse(page.source)
  table.diff!(actual_table)
end

