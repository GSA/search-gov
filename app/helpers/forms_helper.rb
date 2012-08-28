module FormsHelper
  def render_form_title_link(hit, form, affiliate, search)
    url = form.landing_page_url.present? ? form.landing_page_url : form.url
    link_with_click_tracking(highlight_hit(hit, :title).html_safe, url, @affiliate, @search.query, 0, 'FORM', @search_vertical)
  end

  def render_form_link(link, number_of_pages = nil)
    items = []
    items << link[:file_type] if link[:file_type].present?
    items << link[:file_size] if link[:file_size].present?
    items << "#{number_of_pages} #{'page'.pluralize(number_of_pages.to_i)}" if number_of_pages
    content_tag(:span, "[#{items.join(', ')}]").html_safe
  end
end
