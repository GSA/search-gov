module HeaderTaglineFontFamily
  DEFAULT = 'Georgia, "Times New Roman", serif'.freeze

  ALL = [DEFAULT, FontFamily::DEFAULT_CSS_PROPERTY].push(*FontFamily::PREDEFINED).freeze
end
