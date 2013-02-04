class Affiliates::RawLogsAccessController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate

  def new
    @title = 'Get SFTP Access'
  end

  def create
    Emailer.public_key_upload_notification(params[:txtfile], current_user, @affiliate).deliver
    redirect_to home_affiliates_path, :flash => {:success => 'Public key successfully uploaded. We will email you when your files are ready for download.'}
  rescue Exception => e
    @title = 'Get SFTP Access'
    flash[:error] = "Your public key file could not be processed. Please check the format and try again."
    render :action => :new
  end
end
