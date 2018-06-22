class Sitemap < ActiveRecord::Base
  include Fetchable

  attr_readonly :url

  belongs_to :searchgov_domain

  validates :url, presence: true, uniqueness: true,
   length: {maximum: 2000}, format: {with: /\Ahttps?:\/\/(\w+\.)?\w+\.gov(\/\w+)*(\/|\.\w+)?\z/, message: 'invalid url'}
  validates :last_crawl_status, length: {maximum: 255}

  before_validation :set_searchgov_domain, on: :create
end
