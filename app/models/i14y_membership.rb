class I14yMembership < ApplicationRecord
  include Dupable

  belongs_to :affiliate
  belongs_to :i14y_drawer

  def label
    "#{affiliate.name}:#{i14y_drawer.handle}"
  end
end
