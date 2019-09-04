require 'active_support/concern'

module Pageable
  extend ActiveSupport::Concern

  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50

  included do
    class_eval do
      attr_reader :page, :per_page
      class_attribute :default_page,
                      :default_per_page,
                      instance_writer: false
      initialize_class_attributes
    end
  end

  module ClassMethods
    def initialize_class_attributes
      self.default_page = Pageable::DEFAULT_PAGE
      self.default_per_page = Pageable::DEFAULT_PER_PAGE
    end
  end

  def initialize_pageable_attributes(options = {})
    @page = options[:page].to_i rescue default_page
    @page = default_page unless @page >= default_page

    @per_page = options[:per_page].to_i rescue default_per_page
    max_per_page = [Pageable::MAX_PER_PAGE, default_per_page].max
    @per_page = default_per_page unless (1..max_per_page).cover? @per_page
  end
end
