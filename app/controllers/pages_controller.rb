class PagesController < HighVoltage::PagesController
  layout 'pages'
  before_filter :set_page_title, :only => [:show]
  PAGE_TITLES = {
    :accessibility => "Accessibility",
    :api => "APIs and Web Services",
    :program => "USASearch Program",
    :recalls => "Product Recall Data API",
    :search => "Search.USA.gov",
    :textsize => I18n.t(:need_larger_text),
    :tos => "Terms of Service for USASearch's APIs and Web Services",
    :widgets => "Widgets"
  }

  private
  def set_page_title
    @page_title = PAGE_TITLES[params[:id].to_sym]
  end
end
