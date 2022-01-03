# frozen_string_literal: true

class Template < ApplicationRecord
  serialize :schema, Hash
  has_many :affiliates, inverse_of: :template
  has_many :affiliate_templates, dependent: :destroy, inverse_of: :template

  validates_presence_of :name, :klass, :schema
  validates_uniqueness_of :name, :klass, case_sensitive: true

  attr_readonly :klass # passed to Search Consumer

  def self.default
    find_by_name('Classic')
  end
end
