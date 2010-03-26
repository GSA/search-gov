class Recall < ActiveRecord::Base
  has_many :recall_details, :dependent => :destroy

  validates_presence_of :recall_number, :y2k
  FULL_TEXT_SEARCH_FIELDS = {'Manufacturer' => 2, 'RecallType' => 3, 'Description' => 4, 'Hazard' => 6, 'Country' => 7 }
  FACET_FIELDS = %w{Manufacturer RecallType Hazard Country}

  searchable do
    string :recall_number
    integer :y2k
    time :recalled_on
    integer :recall_year do |recall|
      recall.recalled_on.year unless recall.recalled_on.blank?
    end
    
    string :upc do |recall|
      recall.upc unless recall.upc.blank?
    end
    
    # full-text search fields
    FULL_TEXT_SEARCH_FIELDS.each_key do |detail_type|
      text detail_type.underscore.to_sym do |recall|
        recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == detail_type}.compact
      end
    end

    # facet fields
    FACET_FIELDS.each do |detail_type|
      facet_sym = "#{detail_type}Facet".underscore.to_sym
      string facet_sym, :multiple => true do |recall|
        recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == detail_type}.compact
      end
    end
  end

  def self.search_for(query, options = {}, page = 1, per_page = 10)
    Recall.search do
      keywords query
      with(:recalled_on).between(options[:start_date]..options[:end_date]) unless options[:start_date].blank? || options[:end_date].blank?
      with(:upc).equal_to(options[:upc]) unless options[:upc].blank?
      
      facet :hazard_facet, :zeroes => true, :sort => :count
      facet :country_facet, :zeroes => true, :sort => :count
      facet :manufacturer_facet, :zeroes => true, :sort => :count
      facet :recall_type_facet, :zeroes => true, :sort => :count
      facet :recall_year
      
      order_by :score, :desc
      order_by :y2k, :desc
      
      paginate :page => page, :per_page => per_page
    end
  end

  def self.load_from_csv_file(file_path)
    FasterCSV.foreach(file_path, :headers => true) { |row| process_row(row) }
  end

  def self.load_from_text(csv)
    FasterCSV.parse(csv, :headers => true) { |row| process_row(row) }
  end

  def self.process_row(row)
    recall = Recall.find_by_recall_number(row[0]) || Recall.new(:recall_number => row[0], :y2k => row[1])
    if recall.recalled_on.blank? && row[8]
      recall.recalled_on = Date.parse(row[8]) rescue nil
    end
    FULL_TEXT_SEARCH_FIELDS.each_pair do |detail_type, column_index|
      unless row[column_index].blank? or recall.recall_details.exists?(['detail_type = ? AND detail_value = ?', detail_type, row[column_index]])
        recall.recall_details << RecallDetail.new(:detail_type => detail_type, :detail_value => row[column_index])
      end
    end
    recall.save!
  end

  def to_json(options = {})
    recall_hash = { :recall_number => self.recall_number, :recall_date => self.recalled_on.to_s, :recall_url => self.recall_url, :upc => self.upc, :manufacturers => list_detail("Manufacturer"), :descriptions => list_detail("Description"), :hazards => list_detail("Hazard"), :countries => list_detail("Country"), :recall_types => list_detail("RecallType") }
    recall_hash.to_json
  end

  def recall_url
    "http://www.cpsc.gov/cpscpub/prerel/prhtml#{self.recall_number.to_s[0..1]}/#{self.recall_number}.html" unless self.recall_number.blank?
  end
  
  def upc
    upc_detail = self.recall_details.find(:first, :conditions => ['detail_type = ?', 'UPC'])
    upc_detail ? upc_detail.detail_value : "UNKNOWN"
  end
  
  private

  def list_detail(field)
    self.recall_details.find_all_by_detail_type(field).map{|detail| detail.detail_value}
  end

end
