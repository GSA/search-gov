# frozen_string_literal: true

class SearchgovDocument < ApplicationRecord
  validates :body, presence: true

  store_accessor :header, :Etag

  belongs_to :searchgov_url
end
