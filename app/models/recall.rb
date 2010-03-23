class Recall < ActiveRecord::Base
  has_many :recall_details, :dependent => :destroy
  has_many :auto_recalls, :dependent => :destroy

  validates_presence_of :recall_number, :organization
  
  CPSC_FULL_TEXT_SEARCH_FIELDS = {'Manufacturer' => 2, 'ProductType' => 3, 'Description' => 4, 'Hazard' => 6, 'Country' => 7 }
  CPSC_FACET_FIELDS = %w{Manufacturer ProductType Hazard Country}

  NHTSA_DETAIL_FIELDS = {'ManufacturerCampaignNumber' => 5, 'Manufacturer' => 7, 'Code' => 10, 'PotentialUnitsAffected' => 11, 'NotificationDate' => 12, 'Initiator' => 13, 'ReportDate' => 15, 'PartNumber' => 17, 'FederalMotorVehicleSafetyNumber' => 18, 'DefectSummary' => 19, 'ConsequenceSummary' => 20, 'CorrectiveSummary' => 21, 'Notes' => 22 }
  NHTSA_FULL_TEXT_SEARCH_FIELDS = {'DefectSummary' => 19, 'ConsequenceSummary' => 20, 'CorrectiveSummary' => 21, 'Notes' => 22}
  NHTSA_FACET_FIELDS = %w{Make Model Year}
  
  searchable do
    string :organization
    string :recall_number
    time :recalled_on
    
    integer :recall_year do |recall|
      recall.recalled_on.year unless recall.recalled_on.blank?
    end
    
    string :upc do |recall|
      recall.upc unless recall.upc.blank?
    end
    
    # full-text search fields
    CPSC_FULL_TEXT_SEARCH_FIELDS.each_key do |detail_type|
      text detail_type.underscore.to_sym do |recall|
        recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == detail_type}.compact
      end
    end

    # facet fields
    CPSC_FACET_FIELDS.each do |detail_type|
      facet_sym = "#{detail_type}Facet".underscore.to_sym
      string facet_sym, :multiple => true do |recall|
        recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == detail_type}.compact
      end
    end
    
    string :make_facet, :multiple => true do |recall|
      recall.auto_recalls.map {|auto_recall| auto_recall.make.downcase }.compact
    end
    
    string :model_facet, :multiple => true do |recall|
      recall.auto_recalls.map {|auto_recall| auto_recall.model.downcase }.compact
    end
    
    integer :year_facet, :multiple => true do |recall|
      recall.auto_recalls.map {|auto_recall| auto_recall.year }.compact if recall.organization == 'NHTSA'
    end
    
    string :code do |recall|
      code_detail = recall.recall_details.find_by_detail_type("Code")
      code_detail.detail_value if code_detail
    end
    
    NHTSA_FULL_TEXT_SEARCH_FIELDS.each_key do |detail_type|
      text detail_type.underscore.to_sym do |recall|
        recall_detail = recall.recall_details.find_by_detail_type(detail_type)
        recall_detail.detail_value if recall_detail
      end
    end
  end

  def self.search_for(query, options = {}, page = 1, per_page = 10)
    Recall.search do
      keywords query
      
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
      
      facet :hazard_facet, :sort => :count
      facet :country_facet, :sort => :count
      facet :manufacturer_facet, :sort => :count
      facet :product_type_facet, :sort => :count
      facet :recall_year
      
      facet :make_facet, :sort => :count
      facet :model_facet, :sort => :count
      facet :year_facet, :sort => :count
      
      order_by :score, :desc
            
      paginate :page => page, :per_page => per_page
    end
  end

  def self.load_cpsc_data_from_file(file_path)
    FasterCSV.foreach(file_path, :headers => true) { |row| process_cpsc_row(row) }
  end

  def self.load_cpsc_data_from_text(csv)
    FasterCSV.parse(csv, :headers => true) { |row| process_cpsc_row(row) }
  end
  
  def self.load_nhtsa_data_from_file(file_path)
    File.open(file_path).each do |line|
      row = []
      line.split("\t").each { |field| row << field.chomp }
      process_nhtsa_row(row)
    end
  end

  def to_json(options = {})
    recall_hash = { :organization => self.organization, :recall_number => self.recall_number, :recall_date => self.recalled_on.to_s }
    if self.organization == 'CPSC'
      recall_hash.merge!({ :recall_url => self.recall_url, :upc => self.upc, :manufacturers => list_detail("Manufacturer"), :descriptions => list_detail("Description"), :hazards => list_detail("Hazard"), :countries => list_detail("Country"), :product_types => list_detail("ProductType") })
    else
      nhtsa_hash = { :recall_url => self.recall_url }
      NHTSA_DETAIL_FIELDS.each_pair do |detail_type, column_index|
        recall_detail = self.recall_details.find_by_detail_type(detail_type)
        nhtsa_hash[detail_type.underscore.to_sym] = recall_detail.detail_value unless recall_detail.nil?
      end
      recall_hash.merge!(nhtsa_hash)
      recall_hash.merge!(:records => self.auto_recalls)
    end
    recall_hash.to_json
  end

  def recall_url
    if self.organization == 'CPSC'
      "http://www.cpsc.gov/cpscpub/prerel/prhtml#{self.recall_number.to_s[0..1]}/#{self.recall_number}.html" unless self.recall_number.blank?
    elsif self.organization == 'NHTSA'
      "http://www-odi.nhtsa.dot.gov/recalls/results.cfm?rcl_id=#{self.recall_number}&searchtype=quicksearch&summary=true&refurl=rss"
    end
  end
  
  def upc
    if self.organization == 'CPSC'
      upc_detail = self.recall_details.find(:first, :conditions => ['detail_type = ?', 'UPC'])
      upc_detail ? upc_detail.detail_value : "UNKNOWN"
    end
  end
  
  private
  
  def self.process_cpsc_row(row)
    recall = Recall.find_by_recall_number(row[0]) || Recall.new(:recall_number => row[0], :y2k => row[1], :organization => 'CPSC')
    if recall.recalled_on.blank? && row[8]
      recall.recalled_on = Date.parse(row[8]) rescue nil
    end
    CPSC_FULL_TEXT_SEARCH_FIELDS.each_pair do |detail_type, column_index|
      unless row[column_index].blank? or recall.recall_details.exists?(['detail_type = ? AND detail_value = ?', detail_type, row[column_index]])
        recall.recall_details << RecallDetail.new(:detail_type => detail_type, :detail_value => row[column_index])
      end
    end
    recall.save!
  end
  
  def self.process_nhtsa_row(row)
    recall = Recall.find_by_recall_number(row[1])
    unless recall
      recall = Recall.new(:recall_number => row[1], :organization => 'NHTSA', :recalled_on => Date.parse(row[16]))
      NHTSA_DETAIL_FIELDS.each_pair do |detail_type, column_index|
        recall.recall_details << RecallDetail.new(:detail_type => detail_type, :detail_value => row[column_index]) unless row[column_index].blank?
      end      
    end
    auto_recall = AutoRecall.new(:make => row[2], :model => row[3], :year => row[4].to_i == 9999 ? nil : row[4].to_i , :component_description => row[6], :manufacturer => row[14], :recalled_component_id => row[23])
    auto_recall.manufacturing_begin_date = Date.parse(row[8]) unless row[8].blank?
    auto_recall.manufacturing_end_date = Date.parse(row[9]) unless row[9].blank?
    recall.auto_recalls << auto_recall
    recall.save!
  end

  def list_detail(field)
    self.recall_details.find_all_by_detail_type(field).map{|detail| detail.detail_value}
  end

end
