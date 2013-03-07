class ReportRecipient < ActiveRecord::Base
  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false
end