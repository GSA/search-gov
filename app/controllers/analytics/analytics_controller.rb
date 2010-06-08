class Analytics::AnalyticsController < SslController
  helper :all
  layout "analytics"
  before_filter :require_analyst

  private

  def require_analyst
    return false if require_user == false
    unless current_user.is_analyst?
      redirect_to home_page_url
      return false
    end
  end

  def default_url_options(options={})
    {}
  end
  
  def establish_aws_connection
    AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, 
                                        :secret_access_key => AWS_SECRET_ACCESS_KEY)
  end
end