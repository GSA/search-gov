class Sitemap < ActiveRecord::Base
  include Fetchable

  attr_readonly :url

  belongs_to :searchgov_domain

  validates :url, presence: true, uniqueness: true,
   length: {maximum: 2000}, format: {with: /\Ahttps?:\/\/\w+\.gov\/\w+\.(xml|gz|txt)/, message: 'invalid url'}
  validates :last_crawl_status, length: {maximum: 255}

  before_validation :set_searchgov_domain, on: :create

  private

  def set_searchgov_domain
    self.searchgov_domain = SearchgovDomain.find_or_create_by(domain: URI(url).host)
  end
end
