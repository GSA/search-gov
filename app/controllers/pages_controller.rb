class PagesController < HighVoltage::PagesController
  layout 'pages'
  before_filter :set_page_title, :only => [:show]
  PAGE_TITLES = {
    :api => "APIs and Web Services",
    :program => "USASearch Program",
    :recalls => "Product Recall Data API",
    :search => "Search.USA.gov",
    :tos => "Terms of Service for USASearch's APIs and Web Services",
    :widgets => "Widgets"
  }

  private
  def set_page_title
    @page_title = PAGE_TITLES[params[:id].to_sym]
  end
end
