# frozen_string_literal: true

module SearchDomain
  extend ActiveSupport::Concern

  included do
    belongs_to :affiliate
    before_validation :normalize_domain
    validates_presence_of :domain, :affiliate
    validates_format_of :domain, :with => /\A([a-z0-9]+)?([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(\/[^?.]*)?\z/ix, allow_blank: true
    validates_uniqueness_of :domain, :scope => :affiliate_id

    include InstanceMethods
  end

  module InstanceMethods
    def to_label
      domain
    end

    protected

    def normalize_domain
      self.domain = domain.gsub(/(^https?:\/\/| |\/$)/, '').downcase unless domain.blank?
    end
  end
end

