module BootstrapHelper
  def stacked_pushpin
    content_tag :span, class: 'icon-stack' do
      content = content_tag(:i, nil, class: 'icon icon-circle icon-stack-base')
      content << content_tag(:i, nil, class: 'icon icon-pushpin icon-light')
    end
  end
end
