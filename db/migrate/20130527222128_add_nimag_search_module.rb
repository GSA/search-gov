class AddNimagSearchModule < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'NIMAG', display_name: 'Affiliate Image RSS')
  end

  def down
    SearchModule.delete_all("tag = 'NIMAG'")
  end
end
