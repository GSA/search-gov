class BoostedSite < ActiveRecord::Base
  validates_presence_of :title, :url, :description, :affiliate
  belongs_to :affiliate
end
