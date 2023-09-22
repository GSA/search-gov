# frozen_string_literal: true

class Link < ApplicationRecord
  belongs_to :affiliate

  validates :title, :url, :position, presence: true

  before_save :httpfy_url, if: :needs_http?

  protected

  def needs_http?
    url !~ %r{^(http(s?)://|mailto:)}i
  end

  def httpfy_url
    self.url = "https://#{url}"
  end
end
