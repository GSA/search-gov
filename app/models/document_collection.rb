class DocumentCollection < ActiveRecord::Base
  default_scope order('position ASC, document_collections.id ASC')
  belongs_to :affiliate
  has_many :url_prefixes, :dependent => :destroy
  scope :navigable_only, where(:is_navigable => true).joins(:url_prefixes).select("distinct document_collections.*")
  validates_presence_of :name, :affiliate_id
  validates_uniqueness_of :name, :scope => :affiliate_id

  accepts_nested_attributes_for :url_prefixes, :allow_destroy => true, :reject_if => proc { |a| a['prefix'].blank? }

  def destroy_and_update_attributes(params)
    params[:url_prefixes_attributes].each do |url_prefix_attributes|
      url_prefix = url_prefix_attributes[1]
      url_prefix[:_destroy] = true if url_prefix[:prefix].blank?
    end
    update_attributes(params)
  end
end