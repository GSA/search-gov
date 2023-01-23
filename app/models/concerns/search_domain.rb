# frozen_string_literal: true

module SearchDomain
  extend ActiveSupport::Concern

  included do
    belongs_to :affiliate
    before_validation :normalize_domain
    validates :domain, :affiliate, presence: true

    validates :domain,
              uniqueness: { scope: :affiliate_id, case_sensitive: true },
              format: {
                with: %r{\A([a-z0-9]+)?([\-.]{1}[a-z0-9]+)*\.[a-z]{2,5}(/[^?.]*)?\z}ix
              },
              allow_blank: true

    include InstanceMethods
  end

  module InstanceMethods
    def to_label
      domain
    end

    protected

    def normalize_domain
      self.domain = domain.gsub(%r{(^https?://| |/$)}, '').downcase if domain.present?
    end
  end
end
