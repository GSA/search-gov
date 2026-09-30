# frozen_string_literal: true

module SearchHelper
  SPECIAL_URL_PATH_EXT_NAMES = %w{doc pdf ppt ps rtf swf txt xls docx pptx xlsx}
  def link_to_other_web_results(template, query)
    cleaned_query = URI.encode_www_form_component(query)
    template.sub('{QUERY}', cleaned_query).html_safe
  end

  def display_web_result_extname_prefix(web_result)
    display_result_extname_prefix(web_result['unescapedUrl'])
  end

  def display_result_extname_prefix(url)
    begin
      path_extname = File.extname(URI.parse(url).path)[1..-1]
      if SPECIAL_URL_PATH_EXT_NAMES.include?( path_extname.downcase )
        extname_span(path_extname)
      else
        ''
      end
    rescue
      ''
    end
  end

  def extname_span(extname)
    raw "<span class=\"uext_type\">[#{extname.upcase}]</span> "
  end

  def display_result_description(result)
    truncate_html(translate_bing_highlights(h(result['content'])))
  end

  def news_description(instance)
    truncate_html(translate_bing_highlights(h(instance.description))).sub(/^([^A-Z<])/,'...\1').html_safe
  end

  def translate_bing_highlights(body)
    body.gsub(/\uE000/, '<strong>').gsub(/\uE001/, '</strong>')
  end

  def strip_bing_highlights(body)
    body.gsub(/\uE000/, '').gsub(/\uE001/, '')
  end



  private

  def hidden_field_tag_if_key_exists(param_sym, value = params[param_sym])
    hidden_field_tag param_sym, value if value
  end

  def search_bar_class(search)
    'has-query-term' if search.query.present?
  end
end
