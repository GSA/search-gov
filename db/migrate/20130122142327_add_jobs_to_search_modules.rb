class AddJobsToSearchModules < ActiveRecord::Migration
  def up
    SearchModule.create!(tag: 'JOBS', display_name: 'Jobs')
  end

  def down
    SearchModule.where(tag: 'JOBS').destroy_all
  end
end
