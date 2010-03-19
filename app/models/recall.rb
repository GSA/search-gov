class Recall < ActiveRecord::Base
  require 'fastercsv'
  has_many :recall_details, :dependent => :destroy
  
  validates_presence_of :recall_number, :y2k
  
  searchable do
    integer :recall_number
    integer :y2k
    time :recalled_on
    integer :recall_year do |recall|
      recall.recalled_on.year unless recall.recalled_on.blank?
    end
    
    # full-text search fields
    text :description do |recall|
      recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == 'Description'}.compact
    end
    text :manufacturer do |recall|
      recall.recall_details.map{|detail| detail.detail_value if detail.detail_type == 'Manufacturer'}.compact
    end
    text :recall_type do |recall|
      recall.recall_details.map{|detail| detail.detail_value if detail.detail_type == 'RecallType'}.compact
    end
    text :hazard do |recall|
      recall.recall_details.map{|detail| detail.detail_value if detail.detail_type == 'Hazard'}.compact
    end
    text :country do |recall|
      recall.recall_details.map{|detail| detail.detail_value if detail.detail_type == 'Country'}.compact
    end
    
    # facet fields
    string :manufacturer_facet, :multiple => true do |recall|
      recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == 'Manufacturer'}.compact
    end
    string :recall_type_facet, :multiple => true do |recall|
      recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == 'RecallType'}.compact
    end
    string :hazard_facet, :multiple => true do |recall|
      recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == 'Hazard'}.compact
    end
    string :country_facet, :multiple => true do |recall|
      recall.recall_details.map {|detail| detail.detail_value if detail.detail_type == 'Country'}.compact
    end
  end
  
  def self.search_for(query, start_date = nil, end_date = nil, page = 1, per_page = 10)
    Recall.search do
      keywords query
      if start_date && end_date
        with(:recalled_on).between(start_date..end_date)
      end
      facet :hazard_facet, :zeroes => true, :sort => :count
      facet :country_facet, :zeroes => true, :sort => :count
      facet :manufacturer_facet, :zeroes => true, :sort => :count
      facet :recall_type_facet, :zeroes => true, :sort => :count
      facet :recall_year
      order_by :score, :asc
      order_by :y2k, :desc
      paginate :page => page, :per_page => per_page
    end
  end
        
  def self.load_from_csv_file(file_path)
    FasterCSV.foreach(file_path, :headers => true) do |row|
      process_row(row)
    end
  end
  
  def self.load_from_text(csv)
    FasterCSV.parse(csv, :headers => true) do |row|
      process_row(row)
    end
  end
  
  def self.process_row(row)
    recall = Recall.find_by_recall_number(row[0])
    unless recall
      recall = Recall.new(:recall_number => row[0], :y2k => row[1])
    end
    if recall.recalled_on.blank? && row[8]
      recalled_on = Date.parse(row[8]) rescue()
      recall.recalled_on = recalled_on
    end
    if row[2]
      unless recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Manufacturer', row[2]])
        recall.recall_details << RecallDetail.new(:detail_type => 'Manufacturer', :detail_value => row[2])
      end
    end
    if row[3]
      unless recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'RecallType', row[3]])
        recall.recall_details << RecallDetail.new(:detail_type => 'RecallType', :detail_value => row[3])
      end
    end
    if row[4]
      unless recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Description', row[4]])
        recall.recall_details << RecallDetail.new(:detail_type => 'Description', :detail_value => row[4])
      end
    end
    if row[6]
      unless recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Hazard', row[6]])
        recall.recall_details << RecallDetail.new(:detail_type => 'Hazard', :detail_value => row[6])
      end
    end
    if row[7]
      unless recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Country', row[7]])
        recall.recall_details << RecallDetail.new(:detail_type => 'Country', :detail_value => row[7])
      end
    end
    recall.save
  end
  
  def to_json(options = {})
    recall_hash = { :recall_number => self.recall_number, :recall_date => self.recalled_on.to_s, :recall_url => self.recall_url, :manufacturers => list_detail("Manufacturer"), :descriptions => list_detail("Description"), :hazards => list_detail("Hazard"), :countries => list_detail("Country"), :recall_types => list_detail("RecallType") }
    recall_hash.to_json
  end
  
  def recall_url
    "http://www.cpsc.gov/cpscpub/prerel/prhtml#{self.recall_number.to_s[0..1]}/#{self.recall_number}.html" unless self.recall_number.blank?
  end
  
  private
  
  def list_detail(field)
    self.recall_details.find_all_by_detail_type(field).map{|detail| detail.detail_value}
  end
  
end
