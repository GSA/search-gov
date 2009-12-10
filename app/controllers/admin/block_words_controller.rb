class Admin::BlockWordsController < Admin::AdminController
  before_filter :require_affiliate_admin

  active_scaffold :block_words
end