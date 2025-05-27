class AddSearchElasticModule < ActiveRecord::Migration[7.1]
  def change
    SearchModule.create(tag: 'SRCH', display_name: 'Search Elastic')
  end
end
