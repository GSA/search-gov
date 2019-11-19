module BootstrapHelper
  FLASH_TYPE_WHITELIST = %w[success block notice info error danger]

  def stacked_pushpin
    stacked_icon 'thumb-tack'
  end

  def stacked_envelope
    stacked_icon 'envelope'
  end

  def stacked_filter
    stacked_icon 'filter'
  end

  def stacked_icon(icon_name)
    content_tag :span, class: 'fa-stack' do
      content = content_tag(:i, nil, {
        'class' => 'fa fa-circle fa-stack-2x',
        'data-grunticon-embed' => 'toggle_me'
      })
      content << content_tag(:i, nil, {
        'class' => "fa fa-#{icon_name} fa-stack-1x",
        'data-grunticon-embed' => 'toggle_me'
      })
    end
  end

  def button_to_delete_form(name, path, confirm_message)
    button_to name, path,
              method: :delete,
              data: { confirm: confirm_message },
              class: 'btn btn-small'
  end

  def navigation_switch_cell(form, nav, index)
    label_content = "Is #{nav.navigable_type.titleize} #{index} navigable"
    switch_cell(form, :is_active, label_content)
  end

  def switch_cell(form, name, label_content = nil)
    content = switch_button(form, name)

    label_content ||= name.to_s
    cell_id = "#{label_content.downcase.gsub(' ', '_')}_switch"
    content << form.label(name, label_content, class: 'hide')

    content_tag(:td, class: 'cell-1x', id: cell_id) { content }
  end

  def pagination_label(direction)
    if direction == :next
      (I18n.t(:next_label) << '&nbsp;&raquo;').html_safe
    else
      ('&laquo;&nbsp;' << I18n.t(:prev_label)).html_safe
    end
  end

  def render_flash_message(with_close_button = true)
    if flash.present?
      displayable_flash = flash.select { |key, msg| FLASH_TYPE_WHITELIST.include?(key.to_s) }

      html = displayable_flash.map do |key, msg|
        content = ''
        content << button_tag('×', class: 'close', 'data-dismiss' => 'alert') if with_close_button
        content << h(sanitize(msg))
        content_tag(:div, content.html_safe, class: "alert alert-#{key}")
      end
      html.join('\n').html_safe
    end
  end

  private

  def switch_button(form, name)
    content_tag(:div, class: 'switch-button') { form.check_box name }
  end
end
