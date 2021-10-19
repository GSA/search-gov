# frozen_string_literal: true

module HeaderTaglineFontFamily
  DEFAULT = 'Georgia, "Times New Roman", serif'

  ALL = [DEFAULT, FontFamily::DEFAULT_CSS_PROPERTY].push(*FontFamily::PREDEFINED).freeze
end
