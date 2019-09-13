class Connection < ApplicationRecord
  include Dupable

  belongs_to :affiliate
  belongs_to :connected_affiliate, :class_name => "Affiliate"
  validates_presence_of :label
  validate :connected_affiliate_must_be_present
  validate :connected_affiliate_cannot_be_the_same_as_affiliate

  def affiliate_name
    connected_affiliate.nil? ? @affiliate_name : connected_affiliate.name
  end

  def affiliate_name=(affiliate_name)
    @affiliate_name = affiliate_name.present? ? affiliate_name.strip : ''
    self.connected_affiliate = Affiliate.where(:name => @affiliate_name).first
  end

  def connected_affiliate_must_be_present
    unless self.connected_affiliate_id.present?
      if @affiliate_name.present?
        errors.add(:connected_affiliate_id, "#{@affiliate_name} is invalid")
      else
        errors.add(:connected_affiliate_id, "can't be blank")
      end
    end
  end

  def connected_affiliate_cannot_be_the_same_as_affiliate
    if affiliate_id.present? and connected_affiliate_id.present? and affiliate_id == connected_affiliate_id
      errors.add(:connected_affiliate_id, "can't be the same as the current site handle")
    end
  end
end
