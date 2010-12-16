require 'hpricot'
require 'set'

class SitePage < ActiveRecord::Base
  validates_uniqueness_of :url_slug
  validates_presence_of :url_slug

  def self.crawl_usa_gov
    start_page_en = "/site_index.shtml"
    start_page_es = "/gobiernousa/Indice/A.shtml"
    skip_page_en = "/index.shtml"
    skip_page_es = "/gobiernousa/index.shtml"
    base_url = "http://www.usa.gov"
    total, queue = 0, []
    marked = Set.new [skip_page_es, skip_page_en, start_page_en, start_page_es]
    queue.push start_page_en, start_page_es
    transaction do
      delete_all
      while (queue.any?)
        page = queue.pop
        url = base_url + page
        RAILS_DEFAULT_LOGGER.debug "Working on #{url}"
        begin
          doc = open(url) { |f| Hpricot(f) }
          main_content = searchify_usagov_urls((doc/"#main_content").inner_html.squish.gsub(/<!--(.*?)-->/, ""))
          raw_breadcrumb = (doc/"#breadcrumbs_dl").inner_html
          breadcrumb = searchify_usagov_urls(raw_breadcrumb.gsub(/<h2.*h2>/, "").squish)
          url_slug = page.sub(".shtml", "").sub("/", "")
          title = (doc/"#title_dl").inner_html
          create!(:url_slug => url_slug, :title=> title, :breadcrumb => breadcrumb, :main_content => main_content)
          links = (doc/"#main_content//a") + (doc/"#breadcrumbs_dl//a")
          links.each do |link|
            href = link.attributes['href']
            if href.start_with?('/') and href.end_with?('.shtml') and !marked.include?(href)
              queue.push href
              marked.add href
            end
          end
          total += 1
        rescue Exception => e
          RAILS_DEFAULT_LOGGER.error "Trouble fetching #{url}: #{e}"
        end
      end
    end
  end

  private
  def self.searchify_usagov_urls(str)
    str.gsub(".shtml", "").gsub("href=\"http://www.usa.gov/", "href=\"/").gsub("href=\"/", "href=\"/usa/").
      gsub("\"/usa/index\"", "\"/\"").gsub("\"/usa/gobiernousa/index\"", "\"/?locale=es\"")
  end

end
