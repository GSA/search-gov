module FormsHelper
  def render_forms(forms)
    if forms.hits.nil?
      forms.results.each { |f| yield f, nil }
    else
      forms.hits(:verify => true).each { |h| yield h.instance, h }
    end
  end

  def render_form_title_link(hit, form, search, affiliate, search_vertical)
    if hit.present?
      title = highlight_hit(hit, :title)
      number = highlight_hit(hit, :number)
    else
      title = highlight(form.title, search.query, :highlighter => '<strong>\1</strong>')
      number = form.number
    end
    url = form.landing_page_url.present? ? form.landing_page_url : form.url
    link_with_click_tracking("#{title} (#{number})".html_safe, url, affiliate, search.query, 0, 'FORM', search_vertical)
  end

  def render_form_links(form)
    content = []
    form.links.each_with_index do |link, index|
      content << content_tag(:li) do
        link_content = []
        link_content << link_to("#{link[:title]}", link[:url])
        items = []
        items << link[:file_type]
        items << link[:file_size] if link[:file_size]
        items << "#{form.number_of_pages} #{'page'.pluralize(form.number_of_pages.to_i)}" if index == 0 && form.number_of_pages
        link_content << content_tag(:span, "[#{items.join(', ')}]")
        link_content.join("\n").html_safe
      end
    end
    content.join("\n").html_safe
  end

  def render_form_description(hit, form, search)
    if hit.present?
      truncate_html_prose_on_words(highlight_hit(hit, :description).html_safe, 255).html_safe
    else
      highlight(truncate(form.description, :length => 255), search.query, :highlighter => '<strong>\1</strong>')
    end
  end
end
