class Membership < ApplicationRecord
  include Dupable

  belongs_to :affiliate
  belongs_to :user

end
