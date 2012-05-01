require 'hpricot'
require 'set'

class SitePage < ActiveRecord::Base
  ANSWER_SITE_CONFIG = {
      :en => {
          :locale => 'en',
          :host => "answers.usa.gov",
          :base_url => "http://answers.usa.gov/system/",
          :home_path => "selfservice.controller?CONFIGURATION=1000&PARTITION_ID=1&CMD=STARTPAGE&USERTYPE=1&LANGUAGE=en&COUNTRY=us",
          :search_start_page_path => "selfservice.controller?pageSize=10&CMD=DFAQ&KEYWORDS=&TOPIC_NAME=All+topics&SUBTOPIC_NAME=All+Subtopics&subTopicType=0&BOOL_SEARCHSTRING=&SIDE_LINK_TOPIC_ID=&SIDE_LINK_SUB_TOPIC_ID=&SUBTOPIC=-1&searchString=",
          :url_slug_prefix => "answers/" },
      :es => {
          :locale => 'es',
          :host => "respuestas.gobiernousa.gov",
          :base_url => "http://respuestas.gobiernousa.gov/system/",
          :home_path => "selfservice.controller?CONFIGURATION=1001&PARTITION_ID=1&CMD=STARTPAGE&USERTYPE=1&LANGUAGE=en&COUNTRY=us",
          :search_start_page_path => "selfservice.controller?pageSize=10&CMD=DFAQ&KEYWORDS=&TOPIC_NAME=All+topics&SUBTOPIC_NAME=All+Subtopics&subTopicType=0&BOOL_SEARCHSTRING=&SIDE_LINK_TOPIC_ID=&SIDE_LINK_SUB_TOPIC_ID=&SUBTOPIC=-1&searchString=",
          :url_slug_prefix => "respuestas/" }
  }
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
      while queue.any?
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
            href = link.attributes['href'].squish
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
    answer_sites << ANSWER_SITE_CONFIG[:en]
    answer_sites << ANSWER_SITE_CONFIG[:es]
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
            doc.search("div#main_content/ul.one_column_bullet/li/a").each do |link|
              url = site[:base_url] + link.attributes['href']
              faq_page = extract_page url, headers, site
              url = nil
              pages << faq_page unless faq_page.blank?
            end
            # get next page of links
            unless doc.search("span.NextSelected").blank?
              next_search_page_path = doc.search("span.NextSelected").first.search('a').first.attributes['href']
              url = site[:base_url] + next_search_page_path
            end

            index_page_content = ''

            if counter == 1
              featured_content = extract_featured_content(headers, site[:locale])
              index_page_content += featured_content unless featured_content.blank?
            end

            # create the index page
            index_page_title = "FAQs (page #{counter})"
            index_page_content += "<h1 class='answer-title'>#{I18n.t(:top_questions, :locale => site[:locale])}</h1>"
            index_page_content += "<ul>"
            pages.each do |page|
              index_page_content += "<li><a href='/usa/#{page.url_slug}'>#{page.title}</a></li>"
            end
            index_page_content += "</ul>"

            index_page_content += "<p>"
            index_page_content += "<a href='/usa/#{site[:url_slug_prefix]}#{counter - 1}'>#{I18n.t(:prev_label, :locale => site[:locale])}</a>&nbsp;" unless counter == 1
            index_page_content += "<a href='/usa/#{site[:url_slug_prefix]}#{counter + 1}'>#{I18n.t(:next_label, :locale => site[:locale])}</a>" unless url.nil?
            index_page_content += "</p>"
            index_page_slug = "#{site[:url_slug_prefix]}#{counter}"
            SitePage.create(:url_slug => index_page_slug, :title => index_page_title, :main_content => index_page_content)
          end
        rescue Exception => e
          Rails.logger.error "Trouble fetching #{url}\n#{e.message}\n#{e.backtrace.join("\n")}"
          url = nil
        end
      end
    end
  end

  def self.extract_featured_content(headers, locale)
    begin
      answer_site = ANSWER_SITE_CONFIG[locale.to_sym]
      url = answer_site[:base_url] + answer_site[:home_path]
      doc = open(url, headers) { |f| Hpricot(f) }
      url = nil
      unless doc.blank?
        pages = []
        home_features = doc.search("div#home_features").last
        home_features.search('a').each do |link|
          url = "http://" + answer_site[:host] + link.attributes['href']
          link_page = extract_page(url, headers, answer_site)
          pages << link_page unless link_page.blank?
        end
        # create the index page
        return nil if pages.blank?
        index_page_content = "<h1 class='answer-title'>#{I18n.t(:featured_content, :locale => answer_site[:locale])}</h1>"
        index_page_content += "<ul>"
        pages.each do |page|
          index_page_content += "<li><a href='/usa/#{page.url_slug}'>#{page.title}</a></li>"
        end
        index_page_content += "</ul>"
        index_page_content
      end
    rescue => e
      Rails.logger.error "Trouble fetching #{url}\n#{e.message}\n#{e.backtrace.join("\n")}"
      nil
    end
  end

  private

  def self.searchify_usagov_urls(str)
    str.gsub(".shtml", "").gsub("href=\"http://www.usa.gov/", "href=\"/").gsub("href=\"/", "href=\"/usa/").
      gsub("\"/usa/index\"", "\"/\"").gsub("\"/usa/gobiernousa/index\"", "\"http://m.gobiernousa.gov/\"")
  end

  def self.get_cookies(url, host)
    http = Net::HTTP.new(host, 80)
    response = http.post(url,{})
    response['set-cookie']
  end

  def self.extract_page(url, headers, answer_site)
    begin
      link_doc = open(url, headers) { |f| Hpricot(f) }
      url = nil
      title = link_doc.search("div#main_content/h1").remove
      body = link_doc.search("div#main_content/p").remove
      links = link_doc.search("div#main_content/ul").remove
      links = Hpricot::Elements[links.last]
      content = title + body + links
      title_text = title.inner_html
      link_page = SitePage.find_or_initialize_by_url_slug("#{answer_site[:url_slug_prefix]}#{title_text.parameterize}")
      link_page.update_attributes!(:title => title_text, :main_content => content.to_s)
      link_page
    rescue => e
      Rails.logger.error "Trouble fetching #{url}\n#{e.message}\n#{e.backtrace.join("\n")}"
      nil
    end
  end
end
