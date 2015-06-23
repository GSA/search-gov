Then(/^"(.*?)" should receive the "(.*?)" mandrill email$/) do |email_address, template_name|
  user = User.find_by_email(email_address)
  MandrillAdapter.new.last_user.should == user
  MandrillAdapter.new.last_template_name.should == template_name
end

When(/^I visit the password reset page using the perishable token for "(.*?)"$/) do |email_address|
  user = User.find_by_email(email_address)
  visit edit_password_reset_path(user.perishable_token)
end
