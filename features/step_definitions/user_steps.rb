Given /^I am logged in with email "([^"]*)"$/ do |email|
  LoginDotGovTestUtilities.fake_login(email: email)
  visit '/auth/logindotgov'
end

When /^I log in with email "([^"]*)" and password "([^"]*)"/ do |email, dummy_password|
  LoginDotGovTestUtilities.fake_login(email: email)
  visit '/auth/logindotgov'
end

When /^I sign out$/ do
  email = find '#nav-auth-menu a[data-toggle=dropdown]'
  click_link email.text
  find('#nav-auth-menu.dropdown.open')
  click_link 'Sign out'
end

Given /^the following Users exist:$/ do |table|
  table.hashes.each do |hash|
    @user = User.create!(hash.merge(organization_name: 'Agency'))
    @user.update!(approval_status: hash[:approval_status]) if hash[:approval_status].present?
  end
end

When /^(?:I|they) click the complete registration link in the email$/ do
  click_email_link_matching /sites/
end

When(/^I visit the login page/) do
  visit login_path
end
