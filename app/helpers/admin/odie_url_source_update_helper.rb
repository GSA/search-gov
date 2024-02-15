# frozen_string_literal: true

module Admin::OdieUrlSourceUpdateHelper
  def disable_update_button?(affiliate)
    affiliate.indexed_documents.where(source: 'rss').count.zero?
  end

  def update_label(affiliate)
    if disable_update_button?(affiliate)
      t('admin.odie_url_source_update.form.no_documents', scope: 'super_admin')
    else
      t('admin.odie_url_source_update.form.update_affiliate', scope: 'super_admin', affiliate_name: affiliate.name)
    end
  end
end
