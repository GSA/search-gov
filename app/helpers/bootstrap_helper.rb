module BootstrapHelper
  def stacked_pushpin
    stacked_icon 'pushpin'
  end

  def stacked_envelope
    stacked_icon 'envelope'
  end

  def stacked_icon(icon_name)
    content_tag :span, class: 'icon-stack' do
      content = content_tag(:i, nil, class: 'icon icon-circle icon-stack-base')
      content << content_tag(:i, nil, class: "icon icon-#{icon_name} icon-light")
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
      content_tag(:span, I18n.t(:next_label)) <<
          content_tag(:span, nil, class: 'glyphicon glyphicon-chevron-right')
    else
      content_tag(:span, nil, class: 'glyphicon glyphicon-chevron-left') <<
          content_tag(:span, I18n.t(:prev_label))
    end
  end

  def render_flash_message(with_close_button = true)
    if flash.present?
      html = flash.map do |key, msg|
        content = ''
        content << button_tag('×', class: 'close', 'data-dismiss' => 'alert') if with_close_button
        content << msg
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
