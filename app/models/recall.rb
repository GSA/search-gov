class Recall < ActiveRecord::Base
  has_many :recall_details, :dependent => :destroy
  has_many :auto_recalls, :dependent => :destroy
  has_one :food_recall, :dependent => :destroy

  validates_presence_of :recall_number, :organization

  VALID_ORGANIZATIONS = %w{NHTSA CPSC CDC}
  CPSC_FULL_TEXT_SEARCH_FIELDS = {'Manufacturer' => 2, 'ProductType' => 3, 'Description' => 4, 'UPC' => 5, 'Hazard' => 7, 'Country' => 8 }
  CPSC_FACET_FIELDS = %w{Manufacturer ProductType Hazard Country}

  NHTSA_DETAIL_FIELDS = {'ManufacturerCampaignNumber' => 5, 'ComponentDescription'=> 6, 'Manufacturer' => 7,
                         'Code' => 10, 'PotentialUnitsAffected' => 11, 'NotificationDate' => 12,
                         'Initiator' => 13, 'ReportDate' => 15, 'PartNumber' => 17,
                         'FederalMotorVehicleSafetyNumber' => 18, 'DefectSummary' => 19, 'ConsequenceSummary' => 20,
                         'CorrectiveSummary' => 21, 'Notes' => 22, 'RecallSubject' => 25}
  NHTSA_FULL_TEXT_SEARCH_FIELDS = {'ComponentDescription'=> 6, 'DefectSummary' => 19, 'ConsequenceSummary' => 20,
                                   'CorrectiveSummary' => 21, 'Notes' => 22}
  NHTSA_FACET_FIELDS = %w{Make Model Year}

  searchable do
    string :organization
    string :recall_number
    time :recalled_on

    boost do |recall|
      boost_value = Time.parse(recall.recalled_on.to_s).to_i
      boost_value unless recall.recalled_on.blank?
    end

    integer :recall_year do |recall|
      recall.recalled_on.year unless recall.recalled_on.blank?
    end

    string :upc, :multiple => true do |recall|
      recall.upc unless recall.upc.nil?
    end

    # full-text search fields
    CPSC_FULL_TEXT_SEARCH_FIELDS.each_key do |detail_type|
      text detail_type.underscore.to_sym, :stored => true do |recall|
        recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == detail_type}.compact if recall.organization == 'CPSC'
      end
    end

    # facet fields
    CPSC_FACET_FIELDS.each do |detail_type|
      facet_sym = "#{detail_type}Facet".underscore.to_sym
      string facet_sym, :multiple => true do |recall|
        recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == detail_type}.compact if recall.organization == 'CPSC'
      end
    end

    string :make_facet, :multiple => true do |recall|
      recall.auto_recalls.map {|auto_recall| auto_recall.make.downcase }.compact if recall.organization == 'NHTSA'
    end

    string :model_facet, :multiple => true do |recall|
      recall.auto_recalls.map {|auto_recall| auto_recall.model.downcase }.compact if recall.organization == 'NHTSA'
    end

    integer :year_facet, :multiple => true do |recall|
      recall.auto_recalls.map {|auto_recall| auto_recall.year }.compact if recall.organization == 'NHTSA'
    end

    string :code do |recall|
      if recall.organization == 'NHTSA'
        code_detail = recall.recall_details.find_by_detail_type("Code")
        code_detail.detail_value if code_detail
      end
    end

    NHTSA_FULL_TEXT_SEARCH_FIELDS.each_key do |detail_type|
      text detail_type.underscore.to_sym, :stored => true do |recall|
        if recall.organization == 'NHTSA'
          recall_detail = recall.recall_details.find_by_detail_type(detail_type)
          recall_detail.detail_value if recall_detail
        end
      end
    end

    text :food_recall_summary, :stored => true do
      food_recall.summary unless organization != 'CDC' or food_recall.nil?
    end

    text :food_recall_description, :stored => true do
      food_recall.description unless organization != 'CDC' or food_recall.nil?
    end

    string :food_type do
      food_recall.food_type unless organization != 'CDC' or food_recall.nil?
    end
  end

  class << self
    include QueryPreprocessor
    RECALL_RE_EN = /\brecalls?\b/i
    RECALL_RE_ES = /\bretirad[oa]s?\b/i

    def recent(query)
      if recall_query?(query)
        this_month_results = search_for(query, {:start_date=>1.month.ago.to_date, :end_date=>Date.current, :sort => "date"}, 1, 3)
        (this_month_results && this_month_results.total > 0) ? this_month_results : search_for(query, {:sort => "date"}, 1, 3)
      end
    end

    def recall_query?(query)
      (query =~ RECALL_RE_EN or query =~ RECALL_RE_ES)
    end

    def search_for(query, options = {}, page = 1, per_page = 10)
      stripped_query = query ? query.gsub(RECALL_RE_EN, '').gsub(RECALL_RE_ES, '').strip : nil
      do_search(stripped_query, options, page, per_page)
    rescue RSolr::Error::Http => error
      Rails.logger.warn "Error in searching for Recalls: #{error.to_s}"
      nil
    end

    def do_search(query, options, page, per_page)
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => {:model=> self.name, :term => query}.merge(options)) do
        search do
          fulltext preprocess(query) do
            highlight :frag_list_builder => 'single'
          end

          # date range fields
          with(:recalled_on).between(options[:start_date]..options[:end_date]) unless options[:start_date].blank? || options[:end_date].blank?

          with(:organization).equal_to(options[:organization]) unless options[:organization].blank?

          # CPSC fields
          with(:upc).equal_to(options[:upc]) unless options[:upc].blank?

          # NHTSA fields
          with(:make_facet).equal_to(options[:make].downcase) unless options[:make].blank?
          with(:model_facet).equal_to(options[:model].downcase) unless options[:model].blank?
          with(:year_facet).equal_to(options[:year]) unless options[:year].blank?
          with(:code).equal_to(options[:code]) unless options[:code].blank?

          # CDC/Food/Drug fields
          with(:food_type).equal_to(options[:food_type]) unless options[:food_type].blank?

          if options[:sort] == "date"
            order_by :recalled_on, :desc
          end

          paginate :page => page, :per_page => per_page
        end
      end
    end

    def load_cpsc_data_from_file(file_path)
      FasterCSV.foreach(file_path, :headers => true) { |row| process_cpsc_row(row) }
    end

    def load_cpsc_data_from_xml_feed(url)
      require 'rexml/document'
      begin
        REXML::Document.new(Net::HTTP.get_response(URI.parse(url)).body).elements.each('message/results/result') do |element|
          process_cpsc_row([
                             element.attributes["recallNo"],
                             element.attributes["y2k"],
                             element.attributes["manufacturer"],
                             element.attributes["type"],
                             element.attributes["prname"],
                             element.attributes["UPC"],
                             nil,
                             element.attributes["hazard"],
                             element.attributes["country_mfg"],
                             element.attributes["recDate"]
                           ])
        end
      rescue Exception => e
        Rails.logger.error(e.message)
      end
    end

    def load_nhtsa_data_from_file(file_path)
      File.open(file_path).each do |line|
        row = []
        line.split("\t").each { |field| row << field.chomp }
        process_nhtsa_row(row)
      end
    end

    def load_nhtsa_data_from_tab_delimited_feed(url)
      begin
        file = Tempfile.new("nhtsa")
        file.write(Net::HTTP.get_response(URI.parse(url)).body)
        file.close
        load_nhtsa_data_from_file(file.path)
      rescue Exception => e
        Rails.logger.error(e.message)
      end
    end

    def load_cdc_data_from_rss_feed(url, food_type)
      require 'rss/2.0'
      begin
        RSS::Parser.parse(Net::HTTP.get_response(URI.parse(url)).body, false).items.each do |item|
          food_recall = FoodRecall.new(:url=>item.link, :summary => item.title, :description => item.description, :food_type => food_type)
          find_or_create_by_recall_number(:recall_number => Digest::MD5.hexdigest(item.link.downcase)[0, 10],
                                          :recalled_on => item.pubDate.to_date, :organization => 'CDC',
                                          :food_recall => food_recall) if food_recall.valid?
        end
      rescue Exception => e
        Rails.logger.error(e.message)
      end
    end
  end

  def to_json(options = {})
    recall_hash = { :organization => self.organization, :recall_number => self.recall_number,
                   :recall_date => self.recalled_on.to_s, :recall_url => self.recall_url}
    detail_hash = case self.organization
      when 'CPSC' then
        cpsc_hash
      when 'NHTSA' then
        nhtsa_hash
      when 'CDC' then
        cdc_hash
                  end
    recall_hash.merge!(detail_hash) unless detail_hash.nil?
    recall_hash.to_json
  end

  def cpsc_hash
    { :upc => self.upc, :manufacturers => list_detail("Manufacturer"),
     :descriptions => list_detail("Description"), :hazards => list_detail("Hazard"), :countries => list_detail("Country"),
     :product_types => list_detail("ProductType")}
  end

  def nhtsa_hash
    nhtsa_hash = { :records => self.auto_recalls }
    NHTSA_DETAIL_FIELDS.each_key do |detail_type|
      recall_detail = self.recall_details.find_by_detail_type(detail_type)
      nhtsa_hash[detail_type.underscore.to_sym] = recall_detail.detail_value unless recall_detail.nil?
    end
    nhtsa_hash
  end

  def cdc_hash
    {:summary => food_recall.summary, :description => food_recall.description}
  end

  def recall_url
    case self.organization
      when 'CPSC' then
        "http://www.cpsc.gov/cpscpub/prerel/prhtml#{self.recall_number.to_s[0..1]}/#{self.recall_number}.html" unless self.recall_number.blank?
      when 'NHTSA' then
        "http://www-odi.nhtsa.dot.gov/recalls/recallresults.cfm?start=1&SearchType=QuickSearch&rcl_ID=#{self.recall_number}&summary=true&PrintVersion=YES"
      when 'CDC' then
        food_recall.url rescue nil
    end
  end

  def summary
    summary = case self.organization
      when 'CPSC' then
        cpsc_summary
      when 'NHTSA' then
        nhtsa_summary
      when 'CDC' then
        cdc_summary
    end
    summary.blank? ? "Click here to see products" : summary
  end

  def cpsc_summary
    recall_details.select {|rd| rd.detail_type=="Description"}.collect{|rd| rd.detail_value}.join(', ')
  end

  def nhtsa_summary
    summary = auto_recalls.collect {|ar| ar.component_description}.uniq.join(', ')
    manufacturers = auto_recalls.collect {|ar| ar.manufacturer}.uniq.join(', ')
    summary << " FROM #{manufacturers}" unless manufacturers.blank?
  end

  def cdc_summary
    food_recall.nil? ? "Click here to see food recall" : food_recall.summary
  end

  def description
    case self.organization
      when 'CPSC' then
         recall_details.select {|rd| rd.detail_type=="ProductType"}.collect{|rd| rd.detail_value}.join(', ')
      when 'NHTSA' then
        "Recall for model#{"s" if auto_recalls.length > 1}: #{auto_recalls.map(&:model).join(", ")}"
      when 'CDC' then
        food_recall.description
    end
  end

  def upc
    if organization == 'CPSC'
      upc_details = recall_details.find_all_by_detail_type('UPC')
      upc_details.collect{|detail| detail.detail_value}
    else
      nil
    end
  end

  def recalled_on_est
    self.recalled_on + 5.hours
  end

  def is_food_recall?
    self.organization == 'CDC'
  end

  def is_product_recall?
    self.organization == 'CPSC'
  end

  def is_auto_recall?
    self.organization == 'NHTSA'
  end

  def industry
    case organization
      when "NHTSA" : :auto
      when "CPSC" : :product
      when "CDC" : food_recall.food_type == "drug" ? :drug : :food
      else :other
    end
  end

  private

  def self.process_cpsc_row(row)
    recall = find_or_initialize_by_recall_number(:recall_number => row[0], :y2k => row[1], :organization => 'CPSC')
    recall.recalled_on ||= Date.parse(row[9]) rescue nil
    CPSC_FULL_TEXT_SEARCH_FIELDS.each_pair do |detail_type, column_index|
      conditions = ['detail_type = ? AND detail_value = ?', detail_type, row[column_index]]
      unless row[column_index].blank? or (!recall.new_record? && recall.recall_details.exists?(conditions))
        recall.recall_details << RecallDetail.new(:detail_type => detail_type, :detail_value => row[column_index])
      end
    end
    recall.save!
  end

  def self.process_nhtsa_row(row)
    date_string = row[24].blank? ? row[16] : row[24]
    recall = find_or_create_by_recall_number(:recall_number => row[1], :organization => 'NHTSA',
                                                    :recalled_on => Date.parse(date_string))
    if recall.recall_details.empty?
      NHTSA_DETAIL_FIELDS.each_pair do |detail_type, column_index|
        recall.recall_details << RecallDetail.new(:detail_type => detail_type, :detail_value => row[column_index]) unless row[column_index].blank?
      end
    end
    year = row[4] == "9999" ? nil : row[4].to_i
    manufacturing_begin_date = row[8].blank? ? nil : Date.parse(row[8])
    manufacturing_end_date = row[9].blank? ? nil : Date.parse(row[9])
    auto_recall = AutoRecall.find_or_initialize_by_recall_id_and_recalled_component_id(
      :recall_id => recall.id, :recalled_component_id => row[23], :make => row[2], :model => row[3], :year => year,
      :component_description => row[6], :manufacturer => row[14], :manufacturing_begin_date => manufacturing_begin_date, :manufacturing_end_date => manufacturing_end_date)
    recall.auto_recalls << auto_recall
    recall.save!
  end

  def list_detail(field)
    self.recall_details.find_all_by_detail_type(field).map{|detail| detail.detail_value}
  end
end
