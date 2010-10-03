Given /^the following Locations exist:$/ do |table|
  table.hashes.each do |hash|
    Location.create(:zip_code => hash["zip_code"], :state => hash['state'], :city => hash['city'], :population => hash['population'], :lat => hash['lat'], :lng => hash['lng'])
  end
end
