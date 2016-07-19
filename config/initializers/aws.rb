aws_credentials = YAML.load_file("#{Rails.root}/config/aws.yml")[Rails.env]

AWS_IMAGE_BUCKET_CREDENTIALS = aws_credentials['image_bucket']
