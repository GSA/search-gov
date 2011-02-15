Given /^I am logged in with email "([^\"]*)" and password "([^\"]*)"$/ do |email, password|
  @current_user = User.find_by_email(email)
  visit login_path
  fill_in "user_session[email]", :with => email
  fill_in "user_session[password]", :with => password
  click_button
end

Given /^the following Users exist:$/ do |table|
  table.hashes.each do |hash|
    User.create(:contact_name => hash[:contact_name], :email => hash[:email], :government_affiliation => true, :password => 'password', :password_confirmation => 'password')
  end
end

