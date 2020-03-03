require 'spec_helper'

describe 'Populate user rake tasks' do

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/populate_user')
    Rake::Task.define_task(:environment)
  end

  let(:user1) { users(:no_first_last_name_1) }
  let(:user2) { users(:no_first_last_name_2) }
  let(:user3) { users(:no_first_last_name_3) }
  let(:user4) { users(:no_first_last_name_4) }

  let(:csv_file_path) do
    Rails.root.join(Rails.root.to_s,
                    'spec',
                    'fixtures',
                    'csv', 'users.csv')
  end


  describe 'usasearch:populate_user_fields:update_first_last_name' do
    let(:task_name) { 'usasearch:populate_user_fields:update_first_last_name' }

    before do
      @rake[task_name].reenable
    end

    it "has 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'populates the first name' do
      @rake[task_name].invoke(csv_file_path)

      expect(user1.first_name).to eq 'Homer'
      expect(user2.first_name).to eq 'Seymour'
      expect(user3.first_name).to eq 'Ned'
      expect(user4.first_name).to eq 'Nelson'
    end

    it 'populates the last name' do
      @rake[task_name].invoke(csv_file_path)

      expect(user1.last_name).to eq 'Simpson'
      expect(user2.last_name).to eq 'Skinner'
      expect(user3.last_name).to eq 'Flanders'
      expect(user4.last_name).to eq 'Muntz'
    end
  end
end
