Given /^the following Auto Recalls exist:$/ do |table|
  table.hashes.each do |hash|
    manufacturers = hash["manufacturer"].split(',')
    components = hash["component_description"].split(',')
    auto_recalls = []
    manufacturers.size.times do |index|
      auto_recalls << AutoRecall.new( :make => 'AMC',
                                      :model => 'some model',
                                      :year => 2006,
                                      :component_description => components[index].strip,
                                      :manufacturer => manufacturers[index].strip,
                                      :recalled_component_id => '00000000001232132002020.strip2V00',
                                      :manufacturing_begin_date => Date.parse('2005-01-01'),
                                      :manufacturing_end_date => Date.parse('2005-12-31'))
    end
    recall = Recall.new(:recall_number=> hash["recall_number"], :organization=>"NHTSA", :recalled_on=> hash["recalled_days_ago"].to_i.days.ago)
    recall.auto_recalls << auto_recalls

    manufacturers = manufacturers.map {|str| str.strip}.uniq.collect { |manufacturer| RecallDetail.new(:detail_type=>"Manufacturer", :detail_value=> manufacturer.strip) }
    components = components.map {|str| str.strip}.uniq.collect { |component_description| RecallDetail.new(:detail_type=>"ComponentDescription", :detail_value=> component_description.strip) }
    recall.recall_details << manufacturers
    recall.recall_details << components

    recall.save!
  end
end