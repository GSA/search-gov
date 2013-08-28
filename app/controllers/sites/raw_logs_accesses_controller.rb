class Sites::RawLogsAccessesController < Sites::SetupSiteController

  def new
  end

  def create
    Emailer.public_key_upload_notification(params[:txtfile], current_user, @site).deliver
    redirect_to site_path(@site), flash: {success: 'Public key successfully uploaded. We will email you when your files are ready for download.'}
  rescue Exception => e
    flash[:error] = "Your public key file could not be processed. Please check the format and try again."
    render action: :new
  end
end
