class Robot < ActiveRecord::Base
  validates_presence_of :domain
  validates_uniqueness_of :domain, :case_sensitive => false
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
    disallows = get_disallows_for_useragent(robots_txt, 'usasearch')
    if disallows.empty?
      robots_txt.rewind
      disallows = get_disallows_for_useragent(robots_txt, '*')
    end
    prefixes_array = []
    disallows.each do |line|
      if line =~ /^Disallow: *\//i
        prefix = line.split(":").last.split('#').first.squish
        prefix = "#{prefix}/" unless prefix.blank? or prefix.ends_with?("/")
        prefixes_array << prefix
      end
    end
    self.prefixes = prefixes_array.uniq.compact.join(',')
  end

  def get_disallows_for_useragent(robots_txt, user_agent)
    robots_txt.slice_before(/User-agent:/i).select {|ua_arr| ua_arr.first.split(':').last.squish == user_agent}.flatten.drop(1)
  end

  def save_or_delete
    if (robots_txt = fetch_robots_txt)
      build_prefixes(robots_txt)
      save
    else
      delete unless new_record?
    end
  end

  def sitemap
    if (robots_txt = fetch_robots_txt)
      robots_txt.readlines.each do |line|
        return line[8..-1].strip if line.start_with?("Sitemap:")
      end
    end
    return nil
  end

  def self.populate_from_indexed_domains
    IndexedDomain.select("distinct domain").each { |result| find_or_initialize_by_domain(result[:domain]).save_or_delete }
  end

  def self.update_for(domain)
    find_or_initialize_by_domain(domain).save_or_delete
    find_by_domain(domain)
  end

end
