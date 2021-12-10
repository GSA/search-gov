# frozen_string_literal: true

module FontFamily
  DEFAULT = 'Default'

  PREDEFINED = [
    'Arial, sans-serif',
    'Helvetica, sans-serif',
    'Tahoma, Verdana, Arial, sans-serif',
    '"Trebuchet MS", sans-serif',
    'Verdana, sans-serif'
  ].freeze

  ALL = [DEFAULT].push(*PREDEFINED).freeze

  DEFAULT_CSS_PROPERTY = '"Maven Pro", "Helvetica Neue", Helvetica, Arial, sans-serif'

  def self.get_css_property_value(font_family_name)
    default?(font_family_name) ? DEFAULT_CSS_PROPERTY : font_family_name
  end

  def self.valid?(font_family_name)
    ALL.include?(font_family_name)
  end

  def self.default?(font_family_name)
    PREDEFINED.exclude?(font_family_name)
  end
end
