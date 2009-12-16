Given /^the following Affiliates exist:$/ do |table|
  table.hashes.each do |hash|
    user = User.find_by_email(hash["contact_email"]) || User.create!(:email=>hash["contact_email"], :password=>"random_string", :password_confirmation=>"random_string", :contact_name=>hash["contact_name"])
    user.update_attribute(:is_affiliate, true)
    Affiliate.create(:name => hash["name"], :user=> user)
  end
end