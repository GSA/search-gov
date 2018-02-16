Given(/^a clear mandrill email history/) do
  MandrillAdapter.new.clear
end

Then(/^"(.*?)" should receive the "(.*?)" mandrill email$/) do |email_address, template_name|
  user = User.find_by_email(email_address)
  MandrillAdapter.new.last_user.should == user
  MandrillAdapter.new.last_template_name.should == template_name
end

Then(/^"(.*?)" should not receive the "(.*?)" mandrill email$/) do |email_address, template_name|
  last_email = [MandrillAdapter.new.last_user.try(:email), MandrillAdapter.new.last_template_name]
  last_email.should_not == [email_address, template_name]
end

Then(/^"(.*?)" should not have received a mandrill email$/) do |email_address|
  user = User.find_by_email(email_address)
  MandrillAdapter.new.last_user.should_not == user
end
