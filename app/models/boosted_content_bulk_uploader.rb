class BoostedContentBulkUploader
  require 'rexml/document'

  def initialize(site)
    @site = site
    @results = { created: 0, updated: 0, success: false }
    @records_hash = []
  end

  def upload(bulk_upload_file)
    filename = bulk_upload_file.original_filename.downcase
    raise ArgumentError unless filename =~ /\.(xml|csv|txt)$/
    filename.ends_with?('.xml') ? parse_xml(bulk_upload_file) : parse_csv(bulk_upload_file)
    import_boosted_contents
  rescue ArgumentError
    @results[:error_message] = "Your filename should have .xml, .csv or .txt extension."
  rescue
    @results[:error_message] = "Your document could not be processed. Please check the format and try again."
    Rails.logger.warn "Problem processing boosted Content document: #{$!}"
  ensure
    return @results
  end

  private

  def parse_xml(xml_file)
    REXML::Document.new(xml_file.read).root.each_element('//entry') do |entry|
      @records_hash << { url: entry.elements["url"].first.to_s, title: entry.elements["title"].first.to_s,
                         description: entry.elements["description"].first.to_s, affiliate_id: @site.id }
    end
  end

  def parse_csv(csv_file)
    CSV.parse(csv_file.read, :skip_blanks => true) do |row|
      @records_hash << { title: row[0], url: row[1], description: row[2], affiliate_id: @site.id }
    end
  end

  def import_boosted_contents
    @records_hash.each { |info| import_boosted_content(info) }
    @results[:success] = true
  end

  def import_boosted_content(attributes)
    boosted_content_attributes = attributes.merge(status: 'active', publish_start_on: Date.current)
    boosted_content = BoostedContent.find_or_initialize_by_url(boosted_content_attributes)
    boosted_content.affiliate_id = attributes[:affiliate_id]
    if boosted_content.new_record?
      boosted_content.save!
      @results[:created] += 1
    else
      boosted_content.update_attributes!(boosted_content_attributes)
      @results[:updated] += 1
    end
    boosted_content
  end

end