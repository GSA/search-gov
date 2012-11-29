require 'set'

class SitePage < ActiveRecord::Base
  ANSWER_SITE_CONFIG = {
    :en => {
      :locale => 'en',
      :host => "answers.usa.gov",
      :base_url => "http://answers.usa.gov/system/",
      :home_path => "/system/selfservice.controller?CONFIGURATION=1000&PARTITION_ID=1&CMD=STARTPAGE&USERTYPE=1&LANGUAGE=en&COUNTRY=us",
      :search_start_page_path => "/system/selfservice.controller?pageSize=10&CMD=DFAQ&KEYWORDS=&TOPIC_NAME=All+topics&SUBTOPIC_NAME=All+Subtopics&subTopicType=0&BOOL_SEARCHSTRING=&SIDE_LINK_TOPIC_ID=&SIDE_LINK_SUB_TOPIC_ID=&SUBTOPIC=-1&searchString=",
      :url_slug_prefix => "answers/"},
    :es => {
      :locale => 'es',
      :host => "respuestas.gobiernousa.gov",
      :base_url => "http://respuestas.gobiernousa.gov/system/",
      :home_path => "/system/selfservice.controller?CONFIGURATION=1001&PARTITION_ID=1&CMD=STARTPAGE&USERTYPE=1&LANGUAGE=en&COUNTRY=us",
      :search_start_page_path => "/system/selfservice.controller?pageSize=10&CMD=DFAQ&KEYWORDS=&TOPIC_NAME=All+topics&SUBTOPIC_NAME=All+Subtopics&subTopicType=0&BOOL_SEARCHSTRING=&SIDE_LINK_TOPIC_ID=&SIDE_LINK_SUB_TOPIC_ID=&SUBTOPIC=-1&searchString=",
      :url_slug_prefix => "respuestas/"}
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
    marked = Set.new [skip_page_es, skip_page_en, start_page_en, start_page_es.downcase]
    queue.push start_page_en, start_page_es
    transaction do
      delete_all
      while queue.any?
        page = queue.pop
        url = base_url + page
        begin
          doc = Nokogiri::HTML(open(url))
          main_content = searchify_usagov_urls(doc.css("#main_content").inner_html.squish.gsub(/<!--(.*?)-->/, ""))
          raw_breadcrumb = doc.css("#breadcrumbs_dl").inner_html
          breadcrumb = searchify_usagov_urls(raw_breadcrumb.gsub(/<h2.*h2>/, "").squish)
          url_slug = page.sub(".shtml", "").sub("/", "")
          title = doc.css("#title_dl").inner_html
          create!(:url_slug => url_slug, :title => title, :breadcrumb => breadcrumb, :main_content => main_content)
          links = doc.css("#main_content//a") + doc.css("#breadcrumbs_dl//a")
          links.each do |link|
            href = link['href'].squish rescue "broken link"
            if href.start_with?('/') and href.end_with?('.shtml') and !marked.include?(href.downcase)
              queue.push href
              marked.add href.downcase
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
      base_url = URI.parse(site[:base_url])
      transaction do
        delete_all(["url_slug LIKE ?", "#{site[:url_slug_prefix]}%"])
        cookies = get_cookies(base_url.merge(site[:home_path]).to_s, site[:host])
        headers = {"Cookie" => cookies}
        url = base_url.merge(site[:search_start_page_path]).to_s
        counter = 0
        while url.present?
          begin
            doc = Nokogiri::HTML(open(url, headers))
            url = nil
            unless doc.blank?
              counter += 1
              pages = []
              doc.css("div#main_content/ul li/a").each do |link|
                url = base_url.merge(link['href']).to_s
                faq_page = extract_page url, headers, site
                url = nil
                pages << faq_page unless faq_page.blank?
              end
              # get next page of links
              unless doc.css("span.NextSelected").blank?
                next_search_page_path = doc.css("span.NextSelected").first.css('a').first['href']
                url = base_url.merge(next_search_page_path).to_s
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
              create!(:url_slug => index_page_slug, :title => index_page_title, :main_content => index_page_content)
            end
          rescue Exception => e
            Rails.logger.error "Trouble fetching #{url}\n#{e.message}\n#{e.backtrace.join("\n")}"
            url = nil
          end
        end
      end
    end
  end

  def self.extract_featured_content(headers, locale)
    answer_site = ANSWER_SITE_CONFIG[locale.to_sym]
    base_url = URI.parse(answer_site[:base_url])
    url = base_url.merge(answer_site[:home_path]).to_s
    doc = Nokogiri::HTML(open(url, headers))
    url = nil
    unless doc.blank?
      pages = []
      home_features = doc.css("div#home_features").last
      home_features.css('a').each do |link|
        url = base_url.merge(link['href']).to_s
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

  def self.searchify_usagov_urls(str)
    str.gsub(".shtml", "").gsub("href=\"http://www.usa.gov/", "href=\"/").gsub("href=\"/", "href=\"/usa/").
      gsub("\"/usa/index\"", "\"/\"").gsub("\"/usa/gobiernousa/index\"", "\"http://m.gobiernousa.gov/\"").gsub('%20', ' ')
  end

  def self.get_cookies(url, host)
    http = Net::HTTP.new(host, 80)
    response = http.post(url, '')
    response['set-cookie']
  end

  def self.extract_page(url, headers, answer_site)
    link_doc = Nokogiri::HTML(open(url, headers))
    url = nil
    title = link_doc.css("div#main_content/h1").remove
    body = link_doc.css("div#main_content")
    body.css("script").each(&:remove)
    body.css("div").each(&:remove)
    body.css("iframe").each(&:remove)
    title_text = title.inner_html
    content = title.to_s + body.inner_html
    link_page = find_or_initialize_by_url_slug("#{answer_site[:url_slug_prefix]}#{title_text.parameterize}")
    link_page.update_attributes!(:title => title_text, :main_content => content.to_s)
    link_page
  rescue => e
    Rails.logger.error "Trouble fetching #{url}\n#{e.message}\n#{e.backtrace.join("\n")}"
    nil
  end
end
