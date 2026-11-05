# frozen_string_literal: true

module LogoAlignment
  ALL = %w[center left right].freeze
  DEFAULT = ALL.first.freeze

  def self.valid?(logo_aligment)
    ALL.include?(logo_aligment)
  end
end
