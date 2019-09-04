module BelongsToFeaturedCollectionDupable
# frozen_string_literal: true

  extend ActiveSupport::Concern
  include Dupable

  module ClassMethods
    def do_not_dup_attributes
      @do_not_dup_attributes ||= %w[featured_collection_id].freeze
    end
  end
end
