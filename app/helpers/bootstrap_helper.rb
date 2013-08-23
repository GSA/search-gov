module BootstrapHelper
  def stacked_pushpin
    content_tag :span, class: 'icon-stack' do
      content = content_tag(:i, nil, class: 'icon icon-circle icon-stack-base')
      content << content_tag(:i, nil, class: 'icon icon-pushpin icon-light')
    end
  end

  def button_to_delete_form(name, path, confirm_message)
    button_to name, path,
              method: :delete,
              data: { confirm: confirm_message },
              class: 'btn btn-small'
  end
end
