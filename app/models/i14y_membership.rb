class I14yMembership < ApplicationRecord
  include Dupable

  belongs_to :affiliate, inverse_of: :i14y_memberships
  belongs_to :i14y_drawer, inverse_of: :i14y_memberships

  def label
    "#{affiliate.name}:#{i14y_drawer.handle}"
  end
end
