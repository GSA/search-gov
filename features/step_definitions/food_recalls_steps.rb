Given /^the following Food Recalls exist:$/ do |table|
  table.hashes.each do |hash|
    recall = Recall.new(:recall_number=> Digest::MD5.hexdigest(hash["url"])[0,10], :organization=>"CDC", :recalled_on=> hash["recalled_days_ago"].to_i.days.ago)
    recall.food_recall = FoodRecall.new(:url => hash["url"].strip, :summary =>hash["summary"].strip, :description => hash["description"].strip)
    recall.save!
  end
end