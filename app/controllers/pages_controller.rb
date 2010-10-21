class PagesController < HighVoltage::PagesController
  layout 'pages'
  
  def top_searches_widget
    render :layout => false
  end
end