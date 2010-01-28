class Faq < ActiveRecord::Base
  validates_presence_of :url, :question, :answer, :ranking
  validates_numericality_of :ranking, :only_integer => true
end
