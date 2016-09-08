class Language < ActiveRecord::Base
  validates_presence_of :code, :name
  validates_uniqueness_of :code, case_sensitive: false
  has_many :affiliates, foreign_key: :locale, primary_key: :code
end
