class SearchgovDomain < ActiveRecord::Base
  validate :valid_domain?, on: :create
  has_many :searchgov_urls, dependent: :destroy

  attr_readonly :domain

  def delay
    @delay ||= begin
      robotex = Robotex.new 'usasearch'
      robotex.delay("http://#{domain}/") || 1
    end
  end

  def index_urls
    SearchgovDomainIndexerJob.perform_later(self, delay)
  end

  private

  def valid_domain?
    errors.add(:domain, 'is invalid') unless PublicSuffix.valid?(domain)
  end
end
