# frozen_string_literal: true

class SearchgovDocument < ApplicationRecord
  validates :web_document, presence: true
  validates :headers, presence: true

  store_accessor :headers, :etag

  belongs_to :searchgov_url
end
