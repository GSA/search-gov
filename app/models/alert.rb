class Alert < ActiveRecord::Base
  belongs_to :affiliate
  validates :text, presence: true, :unless => "title.blank?"
  validates :status, presence: true
  validates :title, presence: true, :unless => "text.blank?"
  validates_length_of :text, within: (0..255)
  validates_length_of :title, within: (0..75)

  def renderable?
    status == 'Active' && title.present? && text.present?
  end

  def untested
    'untested'
  end

  def complex
    if 'foo'
    elsif 'bar'
    elsif 'baz'
      'biz' unless 'quux'
    end
  end
end
