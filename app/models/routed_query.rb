class RoutedQuery < ActiveRecord::Base
  attr_accessible :url, :description
  belongs_to :affiliate
  has_many :routed_query_keywords, dependent: :destroy

  validates :affiliate, presence: true
  validates_presence_of :url

  def label
    [url, description].join(': ')
  end
end
