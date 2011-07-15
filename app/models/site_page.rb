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
        Rails.logger.debug "Working on #{url}"
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
          Rails.logger.error "Trouble fetching #{url}: #{e}"
        end
      end
    end
  end
  
  def self.crawl_answers_usa_gov
    answer_sites = []
    answer_sites << { :locale => "en",
                      :host => "answers.usa.gov",
                      :base_url => "http://answers.usa.gov/system/", 
                      :home_path => "selfservice.controller?CONFIGURATION=1000&PARTITION_ID=1&CMD=STARTPAGE&USERTYPE=1&LANGUAGE=en&COUNTRY=us",
                      :search_start_page_path => "selfservice.controller?pageSize=10&CMD=DFAQ&KEYWORDS=&TOPIC_NAME=All+topics&SUBTOPIC_NAME=All+Subtopics&subTopicType=0&BOOL_SEARCHSTRING=&SIDE_LINK_TOPIC_ID=&SIDE_LINK_SUB_TOPIC_ID=&SUBTOPIC=-1&searchString=",
                      :url_slug_prefix => "answers/"
                    }
    answer_sites << { :locale => "es",
                      :host => "respuestas.gobiernousa.gov",
                      :base_url => "http://respuestas.gobiernousa.gov/system/", 
                      :home_path => "selfservice.controller?CONFIGURATION=1001&PARTITION_ID=1&CMD=STARTPAGE&USERTYPE=1&LANGUAGE=en&COUNTRY=us",
                      :search_start_page_path => "selfservice.controller?pageSize=10&CMD=DFAQ&KEYWORDS=&TOPIC_NAME=All+topics&SUBTOPIC_NAME=All+Subtopics&subTopicType=0&BOOL_SEARCHSTRING=&SIDE_LINK_TOPIC_ID=&SIDE_LINK_SUB_TOPIC_ID=&SUBTOPIC=-1&searchString=",
                      :url_slug_prefix => "respuestas/"
                    }
    answer_sites.each do |site|
      delete_all(["url_slug LIKE ?", "#{site[:url_slug_prefix]}%"])
      cookies = get_cookies(site[:base_url] + site[:home_path], site[:host])
      headers = { "Cookie" => cookies }
      url = site[:base_url] + site[:search_start_page_path]
      counter = 0
      while url.present?
        begin
          doc = open(url, headers) { |f| Hpricot(f) }
          url = nil
          # step through each result, add it to list of pages to crawl (or crawl)
          unless doc.blank?
            counter += 1
            pages = []
            doc.search("div#main_content/ul.one_column_bullet/li/a").each do |content|
              faq_url = site[:base_url] + content.attributes['href']
              faq_doc = open(faq_url, headers) { |f| Hpricot(f) }
              title = faq_doc.search("div#main_content/h1").remove
              body = faq_doc.search("div#main_content/p").remove
              content = title + body
              title_text = title.inner_html
              faq_page = SitePage.find_or_initialize_by_url_slug("#{site[:url_slug_prefix]}#{title_text.parameterize}")
              faq_page.update_attributes(:title => title_text, :main_content => content.to_s)
              pages << faq_page
            end
            # get next page of links
            unless doc.search("span.NextSelected").blank?
              next_search_page_path = doc.search("span.NextSelected").first.search('a').first.attributes['href']
              url = site[:base_url] + next_search_page_path
            end
            # create the index page
            index_page_title = "FAQs (page #{counter})"
            index_page_content = "<ul>"
            pages.each do |page|
              index_page_content += "<li><a href='/usa/#{page.url_slug}'>#{page.title}</a></li>"
            end
            index_page_content += "</ul>"
            index_page_content += "<p>"
            index_page_content += "<a href='/usa/#{site[:url_slug_prefix]}#{counter - 1}'>Previous</a>&nbsp;" unless counter == 1
            index_page_content += "<a href='/usa/#{site[:url_slug_prefix]}#{counter + 1}'>Next</a>" unless url.nil?
            index_page_content += "</p>"
            index_page_slug = "#{site[:url_slug_prefix]}#{counter}"
            SitePage.create(:url_slug => index_page_slug, :title => index_page_title, :main_content => index_page_content)
          end
        rescue Exception => e
          puts e
          Rails.logger.error "Trouble fetching #{url}: #{e}"
          url = nil
        end
      end
    end
  end

  private
  
  def self.searchify_usagov_urls(str)
    str.gsub(".shtml", "").gsub("href=\"http://www.usa.gov/", "href=\"/").gsub("href=\"/", "href=\"/usa/").
      gsub("\"/usa/index\"", "\"/\"").gsub("\"/usa/gobiernousa/index\"", "\"/?locale=es\"")
  end
  
  def self.get_cookies(url, host)
    http = Net::HTTP.new(host, 80)
    response = http.post(url,{})
    cookies = ""
    cookies = response['set-cookie']
  end
end
