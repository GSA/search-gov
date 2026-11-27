require 'spec_helper'

describe 'SAYT suggestions rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/sayt_suggestions')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:sayt_suggestions' do
    describe 'usasearch:sayt_suggestions:expire' do
      let(:task_name) { 'usasearch:sayt_suggestions:expire' }

      before { @rake[task_name].reenable }

      it "should have 'environment' as a prereq" do
        expect(@rake[task_name].prerequisites).to include('environment')
      end

      context 'when days back is specified' do
        it 'should expire sayt_suggestions that have not been updated for that many days' do
          days_back = '7'
          expect(SaytSuggestion).to receive(:expire).with(days_back.to_i)
          @rake[task_name].invoke(days_back)
        end
      end

      context 'when days back is not specified' do
        it 'should expire sayt_suggestions that have not been updated for 30 days' do
          days_back = '30'
          expect(SaytSuggestion).to receive(:expire).with(days_back.to_i)
          @rake[task_name].invoke
        end
      end
    end
  end
end
