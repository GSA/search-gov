Given(/the following "(.+)" exist:$/) do |klass, table|
  klass = klass.tr(' ','_').classify.constantize
  table.hashes.each{|hash| klass.create!(hash) }
end
