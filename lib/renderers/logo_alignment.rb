module LogoAlignment
  ALL = %w(center left).freeze
  DEFAULT = ALL.first.freeze

  def self.valid?(logo_aligment)
    ALL.include? logo_aligment
  end

  def self.get_logo_alignment_class(site)
    'logo-left' if site.css_property_hash[:logo_alignment] == 'left'
  end
end
