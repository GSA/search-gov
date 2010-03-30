Given /^the following Product Recalls exist:$/ do |table|
  table.hashes.each do |hash|
    manufacturers = hash["manufacturer"].split(',').collect { |manufacturer| RecallDetail.new(:detail_type=>"Manufacturer", :detail_value=> manufacturer.strip) }
    products = hash["product"].split(',').collect { |product| RecallDetail.new(:detail_type=>"Description", :detail_value=> product.strip) }
    recall = Recall.new(:recall_number=> hash["recall_number"], :organization=>"CPSC", :recalled_on=> hash["recalled_days_ago"].to_i.days.ago)
    recall.recall_details << manufacturers
    recall.recall_details << products
    recall.save!
  end
end