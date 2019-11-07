require 'active_support/concern'

module MobileFriendlyController
  extend ActiveSupport::Concern

  included do
    has_mobile_fu
    before_action :set_format_for_table_devices
  end

  private

  def set_format_for_table_devices
    return if request.format && request.format.json?
    request.format = :mobile if is_tablet_device?
  end

  def default_url_options(options= {})
    in_mobile_view? && params[:m] == 'true' ? { m: 'true' } : {}
  end
end
