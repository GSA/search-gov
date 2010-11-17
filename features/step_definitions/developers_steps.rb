Given /^the following developers:$/ do |developers|
  developers.hashes.each do |hash|
    developer = User.new_developer(:contact_name => hash["contact_name"], :email => hash["email"], :password => hash['password'], :password_confirmation => hash['password'])
    developer.save
  end
end
