class AffiliateBroadcast < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :subject
  validates_presence_of :body
end
