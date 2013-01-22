class AddJobsToSearchModules < ActiveRecord::Migration
  def up
    SearchModule.create!(:tag => 'JOBS', :display_name => 'Jobs')
  end

  def down
    SearchModule.destroy_all(:tag => 'JOBS')
  end
end
