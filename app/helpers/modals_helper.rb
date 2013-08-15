module ModalsHelper
  def modal_close_button
    button_tag type: 'button', class: 'close', 'data-dismiss' => 'modal', 'aria-hidden' => 'true' do
      '&times;'.html_safe
    end
  end
end
