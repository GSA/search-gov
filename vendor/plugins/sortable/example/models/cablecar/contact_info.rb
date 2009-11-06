class Cablecar::ContactInfo < ActiveRecord::Base
  set_table_name 'cablecar_contact_infos'
  has_one :user, :class_name => Cablecar::User.to_s
end

# to solve circular dependency
Cablecar::User.class_eval do
  belongs_to :contact_info, :class_name => Cablecar::ContactInfo.to_s  
end