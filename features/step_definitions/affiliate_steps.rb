Given /^the following Affiliates exist:$/ do |table|
  table.hashes.each do |hash|
    valid_options = {:email=>hash["contact_email"], :password=>"random_string", :password_confirmation=>"random_string", :contact_name=>hash["contact_name"], :phone=> "301-123-4567", :address=> "123 Penn Ave", :address2=> "Ste 100", :city=> "Reston", :state=> "VA", :zip=> "20022", :organization_name=> "Agency"}
    user = User.find_by_email(hash["contact_email"]) || User.create!( valid_options )
    user.update_attribute(:is_affiliate, true)
    Affiliate.create(:name => hash["name"], :user=> user)
  end
end