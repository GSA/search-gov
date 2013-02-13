class Admin::AffiliateNotesController < Admin::AdminController
  active_scaffold :affiliate_note do |config|
    config.columns[:note].form_ui = :textarea
  end
end
