Then /I should see the button "(.*)"/ do |button_name|
  assert find_button(button_name)
end

