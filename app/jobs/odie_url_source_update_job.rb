# frozen_string_literal: true

class OdieUrlSourceUpdateJob < ApplicationJob
  queue_as :searchgov

  def perform(affiliate:)
    affiliate.indexed_documents.where(source: 'rss').find_each do |doc|
      doc.update(source: 'manual')
    end
  end
end
