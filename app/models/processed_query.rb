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
    sql = "LOAD DATA LOCAL INFILE '#{filename}' INTO TABLE processed_queries(query, affiliate, times, day) SET created_at=now(), updated_at=now();"
    ActiveRecord::Base.connection.execute(sql) rescue nil
  end
end
