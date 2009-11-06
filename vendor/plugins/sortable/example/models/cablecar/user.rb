class Cablecar::User < ActiveRecord::Base
  set_table_name 'cablecar_users'

  def name
    self.contact_info.name
  end
end