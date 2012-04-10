class Robot < ActiveRecord::Base
  validates_presence_of :domain
  validates_uniqueness_of :domain
  DOWNLOAD_TIMEOUT_SECS = 10

  def disallows?(target_path)
    return false if prefixes.blank?
    prefixes.split(',').any? { |prefix| target_path =~ /^#{prefix}/i }
  end

  def fetch_robots_txt
    timeout(DOWNLOAD_TIMEOUT_SECS) { open("http://" + self.domain + "/robots.txt") }
  rescue Exception => e
    Rails.logger.warn("Couldn't fetch a robots.txt file for #{self.domain}: #{e}")
    nil
  end

  def build_prefixes(robots_txt)
    prefixes_array = []
    robots_txt.each do |line|
      next unless line =~ /^Disallow: *\//
      prefix = line.split(":").last.strip
      prefix = "#{prefix}/" unless prefix.blank? or prefix.ends_with?("/")
      prefixes_array << prefix
    end
    self.prefixes = prefixes_array.uniq.compact.join(',')
  end

  def save_or_delete
    if (robots_txt = fetch_robots_txt)
      build_prefixes(robots_txt)
      save
    else
      delete unless new_record?
    end
  end

  def self.populate_from_indexed_domains
    IndexedDomain.select("distinct domain").each { |result| find_or_initialize_by_domain(result[:domain]).save_or_delete }
  end

end
