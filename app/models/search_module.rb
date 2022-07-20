# frozen_string_literal: true

class SearchModule < ApplicationRecord
  validates_presence_of :tag, :display_name
  validates_uniqueness_of :tag, case_sensitive: true

  def self.to_tag_display_name_hash
    Hash[all.collect { |search_module| [search_module.tag, search_module.display_name] }]
  end
end
