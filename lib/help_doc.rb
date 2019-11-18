require 'open-uri'

module HelpDoc
  def self.extract_article(url)
    doc = Nokogiri::HTML open(url)
    prefix_links_with_scheme_and_host doc
    doc.css('#main-container article.article').first.to_s
  rescue
    "<div class='alert alert-error'>Unable to retrieve <a href='#{url}'>#{url}</a>.</div>"
  end

  def self.prefix_links_with_scheme_and_host(doc)
    doc.css('#main-container a[@href^="/"]').each do |a|
      a['href'] = "#{Rails.application.secrets.organization[:blog_url]}#{a['href']}"
    end
  end
end
