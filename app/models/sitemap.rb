# frozen_string_literal: true

class Sitemap < ApplicationRecord
  include Fetchable

  attr_readonly :url

  belongs_to :searchgov_domain

  before_validation :set_searchgov_domain, on: :create

  # after_create { SitemapIndexerJob.perform_later(sitemap_url: url) }
  # New version -DJMII
  after_create { SitemapIndexerJob.perform_later(sitemap_url: url, domain: searchgov_domain) }

  validates_associated :searchgov_domain, on: :create
  validates_presence_of :searchgov_domain, on: :create

  validates :url, uniqueness: { case_sensitive: false }, presence: true
end
