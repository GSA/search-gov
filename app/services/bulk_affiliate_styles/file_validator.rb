# frozen_string_literal: true

class BulkAffiliateStyles::FileValidator
  MAXIMUM_FILE_SIZE = 4.megabytes
  VALID_CONTENT_TYPES = %w[text/csv].freeze

  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
  end

  def validate!
    ensure_present
    ensure_valid_content_type
    ensure_not_too_big
  end

  def ensure_valid_content_type
    return if VALID_CONTENT_TYPES.include?(@uploaded_file.content_type)

    error_message = "Files of type #{@uploaded_file.content_type} are not supported."
    raise(BulkAffiliateStylesUploader::Error, error_message)
  end

  def ensure_present
    return if @uploaded_file.present?

    error_message = 'Please choose a file to upload.'
    raise(BulkAffiliateStylesUploader::Error, error_message)
  end

  def ensure_not_too_big
    return if @uploaded_file.size <= MAXIMUM_FILE_SIZE

    error_message = "#{@uploaded_file.original_filename} is too big; please split it."
    raise(BulkAffiliateStylesUploader::Error, error_message)
  end
end
