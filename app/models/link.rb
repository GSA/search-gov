# frozen_string_literal: true

class Link < ApplicationRecord
  belongs_to :affiliate

  before_validation :mark_for_destruction, if: :id_but_empty?

  validates :title, :url, :position, presence: true, unless: proc { |l| l.marked_for_destruction? }

  before_save :httpfy_url, if: :needs_http?

  protected

  def id_but_empty?
    !new_record? && (title.blank? && url.blank?)
  end

  def needs_http?
    url !~ %r{^(http(s?)://|mailto:)}i
  end

  def httpfy_url
    self.url = "https://#{url}"
  end
end
