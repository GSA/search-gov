module ListItemWithButtonToRemoveHelper
  def list_item_with_button_to_remove(path, message)
    button = button_to 'Remove', path, method: :delete, data: { confirm: message }, class: 'btn btn-small'
    content_tag :li, button
  end
end
