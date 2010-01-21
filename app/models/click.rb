class Click < ActiveRecord::Base
  
  validates_presence_of :queried_at
  validates_presence_of :url
    
end
