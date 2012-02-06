class Synonym < ActiveRecord::Base
  validates_presence_of :phrase, :alias, :source
  validates_uniqueness_of :alias, :scope => :phrase
  before_validation :set_default_source
  
  private
  
  def set_default_source
    self.source = 'admin' if self.source.blank?
  end
end
