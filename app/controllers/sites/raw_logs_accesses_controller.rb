class Sites::RawLogsAccessesController < Sites::SetupSiteController

  def new
  end

  def create
    public_key_text = params.permit(:txtfile)[:txtfile].tempfile.read
    if public_key_text.present?
      Emailer.public_key_upload_notification(public_key_text, current_user, @site).deliver
      redirect_to site_path(@site), flash: {success: 'Public key successfully uploaded. We will email you when your files are ready for download.'}
    else
      flash[:error] = 'Your public key file could not be processed. Please check the format and try again.'
      render action: :new
    end
  end
end
