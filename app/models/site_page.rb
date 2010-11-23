require 'hpricot'
require 'set'

class SitePage < ActiveRecord::Base
  validates_uniqueness_of :url_slug
  validates_presence_of :url_slug

  def self.crawl_usa_gov
    start_page = "/site_index.shtml"
    skip_page = "/index.shtml"
    base_url = "http://www.usa.gov"
    total = 0
    queue = []
    marked = Set.new [skip_page, start_page]
    queue.push(start_page)
    ActiveRecord::Base.transaction do
      delete_all

      while (queue.any?)
        page = queue.pop
        url = base_url + page
        doc = open(url) { |f| Hpricot(f) }
        main_content = searchify_usagov_urls((doc/"#main_content").inner_html.squish.gsub(/<!--(.*?)-->/, ""))
        raw_breadcrumb = (doc/"#breadcrumbs_dl").inner_html
        breadcrumb = searchify_usagov_urls(raw_breadcrumb.gsub(/<h2.*h2>/, "").squish)
        url_slug = page.gsub(".shtml", "").sub("/", "")
        title = (doc/"#title_dl").inner_html
        create!(:url_slug => url_slug, :title=> title, :breadcrumb => breadcrumb, :main_content => main_content)
        links = (doc/"#main_content//a") + (doc/"#breadcrumbs_dl//a")
        links.each do |link|
          href = link.attributes['href']
          if href.start_with?('/') and not href.start_with?('/gobiernousa') and href.end_with?('.shtml') and !marked.include?(href)
            queue.push(href)
            marked.add href
          end
        end
        total += 1
      end
    end
  end

  private
  def self.searchify_usagov_urls(str)
    str.gsub(".shtml", "").gsub("href=\"/", "href=\"/usa/").gsub("\"/usa/index\"", "\"/\"")
  end

end
