class ProcessedQuery < ActiveRecord::Base
  validates_presence_of :query, :affiliate, :day, :times
  validates_numericality_of :times
     
  searchable do
    text :query, :stored => true
    string :affiliate, :stored => true
    integer :times, :stored => true
    time :day, :trie => true, :stored => true
  end
  
  def self.related_to(query, options = {})
    ProcessedQuery.search do
      request_handler 'relatedSearch'
      keywords query
      with(:affiliate).equal_to(options[:affiliate]) unless options[:affiliate].blank?
      paginate :page => options[:page], :per_page => options[:per_page]
    end  
  end  
  
  def self.load_csv(filename)
    File.open(filename) do |file|
      while line = file.gets
        row = line.split("\t")
        day = Date.parse(row[3][0..10])
        ProcessedQuery.create(:query => row[0], :affiliate => row[1], :times => row[2], :day => day) rescue nil
      end
    end
  end
end
