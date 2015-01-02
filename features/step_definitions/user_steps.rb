Given /^I am logged in with email "([^\"]*)" and password "([^\"]*)"$/ do |email, password|
  @current_user = User.find_by_email(email)
  visit login_path
  fill_in "user_session[email]", :with => email
  fill_in "user_session[password]", :with => password
  click_button('Login')
end

Then /^user "([^\"]*)" should not be approved$/ do |email|
  User.find_by_email(email).approval_status.should == 'not_approved'
end

When /^I sign out$/ do
  email = find '#nav-auth-menu a[data-toggle=dropdown]'
  click_link email.text
  find('#nav-auth-menu.dropdown.open')
  click_link 'Sign out'
end

Given /^the following Users exist:$/ do |table|
  table.hashes.each do |hash|
    User.create!(contact_name: hash[:contact_name], email: hash[:email], password: 'password')
  end
end

When /^(?:I|they) click the complete registration link in the email$/ do
  click_email_link_matching /complete\_registration/
end

