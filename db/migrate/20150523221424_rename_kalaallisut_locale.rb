class RenameKalaallisutLocale < ActiveRecord::Migration
  def up
    kl = Language.find_by_code 'kt'
    kl.update_attribute(:code, 'kl') if kl.present?
  end

  def down
  end
end
