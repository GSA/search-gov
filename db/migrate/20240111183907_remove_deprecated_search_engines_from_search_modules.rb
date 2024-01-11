class RemoveDeprecatedSearchEnginesFromSearchModules < ActiveRecord::Migration[7.0]
  def up
    SearchModule.where(tag: %w[AIMAG AWEB AZCI AZCW BV5I BV5W]).delete_all
  end

  def down
    SearchModule.create(tag: 'AIMAG', display_name: 'Image Results (Azure)')
    SearchModule.create(tag: 'AWEB', display_name: 'Web Results Only (Azure)')
    SearchModule.create(tag: 'AZCI', display_name: 'Image Results (Azure)')
    SearchModule.create(tag: 'AZCW', display_name: 'Web Results Composite (Azure)')
    SearchModule.create(tag: 'BV5I', display_name: 'Image Results (Bing V5)')
    SearchModule.create(tag: 'BV5W', display_name: 'Web Results (Bing V5)')
  end
end
