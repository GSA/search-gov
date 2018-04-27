class SearchgovDomain < ActiveRecord::Base
  validate :valid_domain?, on: :create
  has_many :searchgov_urls, dependent: :destroy

  attr_readonly :domain

  private

  def valid_domain?
    errors.add(:domain, 'is invalid') unless PublicSuffix.valid?(domain)
  end
end
