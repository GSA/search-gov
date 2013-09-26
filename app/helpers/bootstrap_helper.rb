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
end
