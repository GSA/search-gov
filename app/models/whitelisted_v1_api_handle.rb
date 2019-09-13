class WhitelistedV1ApiHandle < ApplicationRecord
  validates_presence_of :handle
  validates_uniqueness_of :handle, case_sensitive: false
end
