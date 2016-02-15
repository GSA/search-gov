class Admin::SearchConsumerTemplatesController < Admin::AdminController
  before_filter :find_affiliate

  def index
    @page_title = 'Search Consumer Templates'

    if !params[:affiliate_id]
      return
    elsif !@affiliate
      flash.now[:error] = "The affiliate ID does not exist." and return
    elsif !@affiliate.search_consumer_search_enabled
      flash.now[:error] = "The affiliate exists, but Search Consumer is not activated." and return
    end
    @affiliate.affiliate_template
  end

  def update
    if @affiliate.affiliate_templates.make_available(selected_template_types) && @affiliate.affiliate_templates.make_unavailable(unselected_template_types) && @affiliate.update_template(params["selected"])
      flash[:success] = "Search Consumer Templates for Affiliate: #{@affiliate.id} have been updated."
    else
      flash[:error] = @affiliate.errors.full_messages

    end
    redirect_to admin_search_consumer_templates_path(affiliate_id: @affiliate.id)
  end

  def port_classic
    @affiliate.port_classic_theme
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
    Template::TEMPLATE_SUBCLASSES.map {|t| t.to_s} - selected_template_types
  end
end
