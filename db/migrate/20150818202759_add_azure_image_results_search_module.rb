class AddAzureImageResultsSearchModule < ActiveRecord::Migration
  def up
    SearchModule.create display_name: 'Image Results (Azure)',
                        tag: 'AIMAG'
  end

  def down
    SearchModule.where(tag: 'AIMAG').delete_all
  end
end
