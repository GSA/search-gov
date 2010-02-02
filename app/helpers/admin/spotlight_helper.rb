module Admin::SpotlightHelper
  def html_form_column(record, input_name)
    fckeditor_textarea(:record, :html, :ajax => true, :width => '800px', :height => '400px')
  end

  def html_column(record)
    sanitize(record.html)
  end
end