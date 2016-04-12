class Sites::TemplatesController < Sites::SetupSiteController
  def edit
  end

  def update
    if @site.update_template(params[:template_class])
      redirect_to(edit_site_template_path(@site), flash: { success: 'You have updated your site Template settings.' })
    else
      render :edit
    end
  end
end
