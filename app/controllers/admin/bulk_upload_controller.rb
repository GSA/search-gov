class Admin::BulkUploadController < Admin::AdminController
  include BulkUploadHandler
  before_action :set_page_title

  def index; end
end
