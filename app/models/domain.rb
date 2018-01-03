class Domain < ActiveRecord::Base
  attr_accessible :domain, :retain_query_strings
  #TODO: validation for domain format
end
