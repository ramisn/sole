When /^I confirm the popup$/ do
  page.driver.browser.switch_to.alert.accept    
end

When /^I dismiss the popup$/ do
  page.driver.browser.switch_to.alert.dismiss
end

# to get the text
# page.driver.browser.switch_to.alert.text