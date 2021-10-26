# frozen_string_literal: true

module LogoAlignment
  ALL = %w[center left right].freeze
  DEFAULT = ALL.first.freeze

  def self.valid?(logo_aligment)
    ALL.include?(logo_aligment)
  end

  def self.get_logo_alignment_class(site)
    logo_alignment = site.css_property_hash[:logo_alignment]
    "logo-#{logo_alignment}" if logo_alignment
  end
end
