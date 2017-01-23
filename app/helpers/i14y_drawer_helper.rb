module I14yDrawerHelper
  def i14y_drawer_data_row(i14y_drawer)
    content = content_tag(:td, i14y_drawer.handle)
    content << content_tag(:td, i14y_drawer.description)
    if i14y_drawer.stats.present?
      content << content_tag(:td, i14y_drawer.stats.document_total)
      last_sent = i14y_drawer.stats.document_total > 0 ? time_ago_in_words(Time.parse(i14y_drawer.stats.last_document_sent)) : nil
      content << content_tag(:td, last_sent)
    else
      content << content_tag(:td)
      content << content_tag(:td)
    end
    content
  end

  def deletion_confirmation(drawer)
    if drawer.affiliates.count > 1
      "Are you sure you want to remove this drawer from this site?"
    else
      "Removing this drawer from this site will delete it from the system. Are you sure you want to delete it?"
    end
  end
end
