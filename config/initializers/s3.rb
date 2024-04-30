S3_CREDENTIALS = {
  access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
  bucket:            ENV['AWS_BUCKET'],
  s3_host_alias:     ENV['AWS_S3_HOST_ALIAS'],
  s3_region:         ENV['AWS_REGION'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
}.freeze
