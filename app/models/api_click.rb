# frozen_string_literal: true

class ApiClick < Click
  attr_reader :affiliate, :access_key

  validates :affiliate, :access_key, presence: true
  validate :validates_active_affiliate
  validate :validates_access_key

  def initialize(params)
    super

    @access_key = params[:access_key]
  end

  private

  def active_affiliate
    @active_affiliate ||= Affiliate.active.find_by(name: affiliate)
  end

  def validates_active_affiliate
    return if affiliate.nil?

    errors.add(:affiliate, 'is invalid') if active_affiliate.nil?
  end

  def validates_access_key
    return if active_affiliate.nil? || access_key.nil?

    errors.add(:access_key, 'is invalid') if active_affiliate.api_access_key != access_key
  end

  def click_hash
    super.merge(tags: ['api'])
  end
end
