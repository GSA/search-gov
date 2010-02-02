Given /^I am logged in with email "([^\"]*)" and password "([^\"]*)"$/ do |email, password|
  @current_user = User.find_by_email(email)
  visit new_user_session_path
  fill_in "Email", :with => email
  fill_in "Password", :with => password
  click_button
end
