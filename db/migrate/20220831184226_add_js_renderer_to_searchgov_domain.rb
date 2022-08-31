class AddJsRendererToSearchgovDomain < ActiveRecord::Migration[6.1]
  def change
    add_column :searchgov_domains, :js_renderer, :boolean, :default => true
  end
end
