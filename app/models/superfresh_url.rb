class SuperfreshUrl < ApplicationRecord
  belongs_to :affiliate
  validates_presence_of :url
  validates_url :url

  MAX_URLS_PER_FILE_UPLOAD = 100
  DEFAULT_URL_COUNT = 500

  class << self
    def uncrawled_urls
      transaction do
        results = first(DEFAULT_URL_COUNT)
        delete(results.collect(&:id)) if results.present?
        results
      end
    end

    def process_file(file, affiliate = nil, max_urls = MAX_URLS_PER_FILE_UPLOAD)
      counter = 0
      if file.tempfile.each_line.count <= max_urls and file.tempfile.open
        file.tempfile.each { |line| counter += 1 if create(:url => line.chomp.strip, :affiliate => affiliate).errors.empty? }
        counter
      else
        raise "Too many URLs in your file.  Please limit your file to #{max_urls} URLs."
      end
    end
  end
end
