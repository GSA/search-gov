# frozen_string_literal: true

require 'English'
class BulkAffiliateStylesUploader
  MAXIMUM_FILE_SIZE = 4.megabytes
  VALID_CONTENT_TYPES = %w[text/csv].freeze
  URL_ALREADY_TAKEN_MESSAGE = 'Validation failed: Url has already been taken'

  attr_reader :results

  class Error < StandardError
  end

  class Results
    attr_accessor :affiliates, :ok_count, :error_count, :file_name

    def initialize(filename)
      @file_name = filename
      @ok_count = 0
      @error_count = 0
      @affiliates = Set.new
      @errors = Hash.new { |hash, key| hash[key] = [] }
    end

    def add_ok(affiliate_id)
      self.ok_count += 1
      affiliates << affiliate_id
    end

    def add_error(error_message, affiliate_id)
      self.error_count += 1
      @errors[affiliate_id] = error_message
    end

    def total_count
      ok_count + error_count
    end

    def affiliates_with(error_message)
      @errors[error_message]
    end
  end

  class AffiliateStylesFileValidator
    def initialize(uploaded_file)
      @uploaded_file = uploaded_file
    end

    def validate!
      ensure_present
      ensure_valid_content_type
      ensure_not_too_big
    end

    def ensure_valid_content_type
      return if BulkAffiliateStylesUploader::VALID_CONTENT_TYPES.include?(@uploaded_file.content_type)

      error_message = "Files of type #{@uploaded_file.content_type} are not supported."
      raise(BulkAffiliateStylesUploader::Error, error_message)
    end

    def ensure_present
      return if @uploaded_file.present?

      error_message = 'Please choose a file to upload.'
      raise(BulkAffiliateStylesUploader::Error, error_message)
    end

    def ensure_not_too_big
      return if @uploaded_file.size <= BulkAffiliateStylesUploader::MAXIMUM_FILE_SIZE

      error_message = "#{@uploaded_file.original_filename} is too big; please split it."
      raise(BulkAffiliateStylesUploader::Error, error_message)
    end
  end

  def initialize(filename, filepath)
    @file_name = filename
    @file_path = filepath
  end

  def upload
    begin
      @results = Results.new(@file_name)
      import_affiliate_styles
    rescue
      @results[:error_message] = 'Your document could not be processed. Please check the format and try again.'
      Rails.logger.error "Problem processing boosted Content document: #{$ERROR_INFO}"
    end
    @results
  end

  private

  def import_affiliate_styles
    CSV.parse(File.read(@file_path), headers: true) do |row|
      affiliate_id = row['ID']
      update_styles(row, affiliate_id)
      @results.add_ok(affiliate_id)
      @results[:updated] += 1
    rescue StandardError => e
      @results.add_error(e.message, affiliate_id)
      Rails.logger.error "Failure to process bulk upload affiliate styles row:\n#{row}\n#{e.message}\n#{e.backtrace.join("\n")}"
      @results[:failed] += 1
    end
  end

  def update_styles(row, affiliate_id)
    affiliate = Affiliate.find(affiliate_id)
    next if affiliate.nil?

    delete_exiting_links(affiliate)
    create_primary_header_links(row, affiliate)
    create_secondary_header_links(row, affiliate)
    create_footer_links(row, affiliate)
    create_identifier_links(row, affiliate)
    misc_settings(row, affiliate)

    affiliate.visual_design_json = visual_design_settings(row)
    affiliate.save!
  end

  def delete_exiting_links(affiliate)
    PrimaryHeaderLink.where(affiliate_id: affiliate.id).delete_all
    SecondaryHeaderLink.where(affiliate_id: affiliate.id).delete_all
    FooterLink.where(affiliate_id: affiliate.id).delete_all
    IdentifierLink.where(affiliate_id: affiliate.id).delete_all
  end

  def create_primary_header_links(row, affiliate)
    12.times do |index|
      title_key = "primary_header_links #{index} - title"
      url_key = "primary_header_links #{index} - url"
      primary_header_link = PrimaryHeaderLink.create(position: index, type: 'PrimaryHeaderLink', title: row[title_key], url: row[url_key], affiliate_id: row['ID'])
      affiliate.primary_header_links << primary_header_link if primary_header_link.valid?
    end
  end

  def create_secondary_header_links(row, affiliate)
    3.times do |index|
      title_key = "secondary_header_links #{index} - title"
      url_key = "secondary_header_links #{index} - url"
      secondary_header_link = SecondaryHeaderLink.create(position: index, type: 'SecondaryHeaderLink', title: row[title_key], url: row[url_key], affiliate_id: row['ID'])
      affiliate.secondary_header_links << secondary_header_link if secondary_header_link.valid?
    end
  end

  def create_footer_links(row, affiliate)
    13.times do |index|
      title_key = "footer_links #{index} - title"
      url_key = "footer_links #{index} - url"
      footer_link = FooterLink.create(position: index, type: 'FooterLink', title: row[title_key], url: row[url_key], affiliate_id: row['ID'])
      affiliate.footer_links << footer_link if footer_link.valid?
    end
  end

  def create_identifier_links(row, affiliate)
    12.times do |index|
      title_key = "identifier_links #{index} - title"
      url_key = "identifier_links #{index} - url"
      identifier_link = IdentifierLink.create(position: index, type: 'IdentifierLink', title: row[title_key], url: row[url_key], affiliate_id: row['ID'])
      affiliate.identifier_links << identifier_link if identifier_link.valid?
    end
  end

  def visual_design_settings(row)
    {
      banner_background_color: row['banner_background_color'],
      banner_text_color: row['banner_text_color'],
      header_background_color: row['header_bg_color'],
      header_text_color: row['header_text_color'],
      header_navigation_background_color: row['header_navigation_background_color'],
      header_primary_link_color: row['header_primary_link_color'],
      header_secondary_link_color: row['header_secondary_link_color'],
      page_background_color: row['page_background_color'],
      button_background_color: row['button_background_color'],
      active_search_tab_navigation_color: row['active_search_tab_navigation_color'],
      search_tab_navigation_link_color: row['search_tab_navigation_link_color'],
      best_bet_background_color: row['best_bet_background_color'],
      health_benefits_header_background_color: row['health_benefits_header_background_color'],
      result_title_color: row['result_title_color'],
      result_title_link_visited_color: row['result_title_link_visited_color'],
      result_description_color: row['result_description_color'],
      result_url_color: row['result_url_color'],
      section_title_color: row['section_title_color'],
      footer_background_color: row['footer_background_color'],
      footer_links_text_color: row['footer_link_text_color'],
      identifier_background_color: row['identifier_background_color'],
      identifier_heading_color: row['identifier_heading_color'],
      identifier_link_color: row['identifier_link_color'],
      footer_and_results_font_family: row['footer_and_results_font_family'],
      header_links_font_family: row['header_links_font_family'],
      identifier_font_family: row['Identifier_font_family'],
      primary_navigation_font_family: row['primary_navigation_font_family'],
      primary_navigation_font_weight: row['Primary_navigation_font_weight']
    }.transform_keys(&:to_s)
  end

  def misc_settings(row, affiliate)
    affiliate.display_logo_only = row['display_logo_only']
    affiliate.identifier_domain_name = row['site_identifier_domain_name']
    affiliate.parent_agency_name = row['site_parent_agency_name']
    affiliate.parent_agency_link = row['site_parent_agency_link']
  end
end
