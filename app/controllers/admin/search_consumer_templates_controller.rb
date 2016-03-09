class Admin::SearchConsumerTemplatesController < Admin::AdminController
  before_filter :find_affiliate

  def index
    @page_title = 'Search Consumer Templates'

    if !@affiliate 
      flash.now[:error] = "The affiliate ID does not exist." and return
    elsif !@affiliate.search_consumer_search_enabled
      flash.now[:error] = "The affiliate exists, but does not have Search Consumer activated." and return
    end
    @affiliate.template
  end

  def update
    if @affiliate.templates.activate(selected_template_types) && @affiliate.templates.deactivate(unselected_template_types) && @affiliate.update_template(params["selected"])
      flash[:success] = "Search Consumer Templates for Affiliate: #{@affiliate.id} have been updated."
    else
      flash[:error] = @affiliate.errors.full_messages
    end
    redirect_to admin_search_consumer_templates_path(affiliate_id: @affiliate.id)
  end

  private 

  def find_affiliate
    @affiliate = Affiliate.find_by_id(params[:affiliate_id])
  end

  def selected_template_types
    params["selected-template-types"] || []
  end

  def unselected_template_types
    Template::TEMPLATE_SUBCLASSES - selected_template_types
  end
end
