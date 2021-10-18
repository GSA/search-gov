module FontFamily
  DEFAULT = 'Default'.freeze

  PREDEFINED = [
      'Arial, sans-serif',
      'Helvetica, sans-serif',
      'Tahoma, Verdana, Arial, sans-serif',
      '"Trebuchet MS", sans-serif',
      'Verdana, sans-serif'
  ]

  ALL = [DEFAULT].push(*PREDEFINED).freeze

  DEFAULT_CSS_PROPERTY = '"Maven Pro", "Helvetica Neue", Helvetica, Arial, sans-serif'.freeze

  def self.get_css_property_value(font_family_name)
    default?(font_family_name) ? DEFAULT_CSS_PROPERTY : font_family_name
  end

  def self.valid?(font_family_name)
    ALL.include? font_family_name
  end

  def self.default?(font_family_name)
    !PREDEFINED.include?(font_family_name)
  end
end
