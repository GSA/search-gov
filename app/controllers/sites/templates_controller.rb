# deprecated - Search Consumer
class Sites::TemplatesController < Sites::SetupSiteController
  def edit
  end

  def update
    if @site.update(template_id: template_id)
      redirect_to(edit_site_template_path(@site),
                  flash: { success: 'You have updated your site Template settings.' })
    else
      render :edit
    end
  end

  private

  def template_id
    params.require(:site).require(:template_id)
  end
end
