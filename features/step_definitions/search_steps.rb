Given /^the following FAQs exist:$/ do |table|
  table.hashes.each do |hash|
    Faq.create!(:url => hash["url"], :question => hash["question"], :answer => hash["answer"], :ranking => hash["ranking"], :locale => hash["locale"])
  end
  Sunspot.commit
end

Given /^the following Calais Related Searches exist:$/ do |table|
  table.hashes.each do |hash|
    CalaisRelatedSearch.create!(:term => hash["term"], :related_terms => hash["related_terms"], :locale => hash["locale"])
  end
  Sunspot.commit
end

