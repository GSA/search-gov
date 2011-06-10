class Spotlight < ActiveRecord::Base
  validates_presence_of :title
  validates_uniqueness_of :title
  has_many :spotlight_keywords, :dependent => :destroy, :order => 'name ASC'
  belongs_to :affiliate
  
  searchable do
    boolean :is_active
    integer :affiliate_id
    text :spotlight_keywords do
      spotlight_keywords.map { |spotlight_keyword| spotlight_keyword.name }
    end
  end

  def self.search_for(query, affiliate = nil)
    ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => {:model=> self.name, :term => query}) do
      solr = search do
        with :is_active, true
        if affiliate.nil?
          with :affiliate_id, nil
        else
          with :affiliate_id, affiliate.id
        end
        keywords query
        paginate :page => 1, :per_page => 1
      end rescue nil
      solr.results.first unless solr.nil? or solr.results.empty?
    end
  end
end
