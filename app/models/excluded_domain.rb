class ExcludedDomain < ActiveRecord::Base
  validates_presence_of :domain

  def self.excludes_host?(host)
    where(["? like concat('%',domain)",host]).any?
  end
end
