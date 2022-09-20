# frozen_string_literal: true

class SearchgovDocument < ApplicationRecord
  # SRCH-3134: web_document stores either:
  # 1. the entire raw html of an html document, or
  # 2. the full metadata and content of an application document of an application document.
  validates :web_document, presence: true
  validates :headers, presence: true

  store_accessor :headers, :etag

  belongs_to :searchgov_url
end
