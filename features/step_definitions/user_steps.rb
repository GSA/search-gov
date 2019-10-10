Given /^I am logged in with email "([^"]*)"$/ do |email|
  OmniAuth.config.test_mode = true

  omniauth_hash = {
    uid: 'test_123',
    info: {
      email: email
    }
  }

  OmniAuth.config.add_mock('logindotgov', omniauth_hash)
  visit '/auth/logindotgov'
end

Given /^I (?:log in) with email "([^\"]*)" and password "([^\"]*)"$/ do |email, password|
  visit login_path
  fill_in "user_session[email]", with: email
  fill_in "user_session[password]", with: password
  click_button('Login')
end

When /^I sign out$/ do
  email = find '#nav-auth-menu a[data-toggle=dropdown]'
  click_link email.text
  find('#nav-auth-menu.dropdown.open')
  click_link 'Sign out'
end

Given /^the following Users exist:$/ do |table|
  table.hashes.each do |hash|
    User.create!(hash.merge(password: 'test1234!', organization_name: 'Agency'))
    if hash[:password_updated_at]
     user = User.find_by_email(hash[:email])
     user.update_attributes(password_updated_at: hash[:password_updated_at].to_date)
    end
  end
end

When /^(?:I|they) click the complete registration link in the email$/ do
  click_email_link_matching /complete\_registration/
end

When(/^I visit the password reset page using the perishable token for "(.*?)"$/) do |email_address|
  user = User.find_by_email(email_address)
  visit edit_password_reset_path(user.perishable_token)
end

When(/^I visit the password reset page using the token "(.*?)"$/) do |token|
  visit edit_password_reset_path(token)
end

When(/^I visit the complete registration page using the email verification token for "(.*?)"$/) do |email_address|
  user = User.find_by_email(email_address)
  visit edit_complete_registration_path(user.email_verification_token)
end

When(/^I visit the email verification page using the email verification token for "(.*?)"$/) do |email_address|
  user = User.find_by_email(email_address)
  visit email_verification_path(user.email_verification_token)
end

When(/^I visit the login page/) do
  visit login_path
end