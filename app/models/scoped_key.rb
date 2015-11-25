class ScopedKey < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :key
end
