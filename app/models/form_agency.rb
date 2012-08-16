class FormAgency < ActiveRecord::Base
  attr_accessible :name, :locale, :display_name
  validates_presence_of :name, :locale, :display_name
  has_many :forms, :dependent => :destroy
  has_and_belongs_to_many :affiliates

  def to_label
    "[#{locale}] #{name}"
  end
end
