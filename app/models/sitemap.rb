class Sitemap < ActiveRecord::Base
  include Fetchable

  attr_readonly :url

  belongs_to :searchgov_domain

  before_validation :set_searchgov_domain, on: :create

  after_create { SitemapIndexerJob.perform_later(sitemap_url: url) }

  validates_associated :searchgov_domain, on: :create
  validates_presence_of :searchgov_domain, on: :create

  validates :url, uniqueness: true, presence: true, case_sensitive: false
end
