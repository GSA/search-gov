aws_credentials = YAML.load_file("#{Rails.root}/config/aws.yml")[Rails.env]

AWS_IMAGE_BUCKET_CREDENTIALS = aws_credentials['image_bucket'] rescue { }
AWS_IMAGE_S3_HOST_ALIAS = aws_credentials['image_bucket']['s3_host_alias'] rescue nil
