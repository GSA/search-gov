class BoostedSite < ActiveRecord::Base
  validates_presence_of :title, :url, :description, :affiliate
  belongs_to :affiliate
  searchable do
    text :title, :description
    integer :affiliate_id
  end

  def self.search_for(affiliate, query)
    BoostedSite.search do
      with :affiliate_id, affiliate.id
      keywords query, :highlight=>true
      paginate :page => 1, :per_page => 3
    end rescue nil
  end
end
