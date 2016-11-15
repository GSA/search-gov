class Admin::SearchConsumerTemplatesController < Admin::AdminController
  before_filter :find_affiliate

  def index
    @page_title = 'Search Consumer Templates'

    if !@affiliate
      flash.now[:error] = "The affiliate ID does not exist." and return
    elsif !@affiliate.search_consumer_search_enabled
      flash.now[:error] = "The affiliate exists, but Search Consumer is not activated." and return
    end
    @affiliate.template
  end

  def update
    if !(selected_template_ids.include? selected_template_id)
      flash[:error] = "Please ensure the selected template is a visible template."
    elsif @affiliate.update_templates(selected_template_id, selected_template_ids)
      flash[:success] = "Search Consumer Templates for #{@affiliate.display_name} have been updated."
    else
      flash[:error] = "Unable to update templates."
    end
    redirect_to admin_affiliate_search_consumer_templates_path(affiliate_id: @affiliate.id)
  end

  def port_classic
    @affiliate.port_classic_theme
    redirect_to admin_affiliate_search_consumer_templates_path(affiliate_id: @affiliate.id)
  end

  private

  def find_affiliate
    @affiliate = Affiliate.find_by_id(params[:affiliate_id])
  end

  def selected_template_id
    params.require(:selected).to_i
  end

  def selected_template_ids
    (params[:selected_template_types] || []).map(&:to_i)
  end
end
