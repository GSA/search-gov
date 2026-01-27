# frozen_string_literal: true

module Attachable
  extend ActiveSupport::Concern

  def header_logo_path
    "#{Rails.env}/site/#{id}/header_logo/#{header_logo.filename}"
  end

  def set_attached_filepath
    header_logo.key = header_logo_path if header_logo.new_record?
  end
end
