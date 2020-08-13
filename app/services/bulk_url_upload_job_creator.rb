# frozen_string_literal: true

class BulkUrlUploadJobCreator
  def initialize(file, user)
    @file = file
    @user = user
  end

  def create_job!
    raise 'Please choose a file to upload' unless @file

    SearchgovUrlBulkUploaderJob.perform_later(@user, save_tempfile)
  end

  def save_tempfile
    validate_file
    redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT)
    redis.set(redis_key, @file.tempfile.read)
    redis_key
  end

  def validate_file
    ensure_valid_content_type
    ensure_not_too_big
  end

  def ensure_valid_content_type
    return if  BulkUrlUploader::VALID_CONTENT_TYPES.include?(@file.content_type)

    error_message = "files of type #{@file.content_type} are not supported."
    raise(BulkUrlUploader::Error, error_message)
  end

  def ensure_not_too_big
    return if  @file.size <= BulkUrlUploader::MAXIMUM_FILE_SIZE

    error_message = "#{@file.original_filename} is too big; please split it into smaller files."
    raise(BulkUrlUploader::Error, error_message)
  end

  def redis_key
    @redis_key ||= "bulk_url_upload:#{@file.original_filename}:#{SecureRandom.uuid}"
  end
end
