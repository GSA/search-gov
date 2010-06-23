require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "Recalls rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/recalls"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:recalls" do

    describe "usasearch:recalls:load_cdc_data" do
      before do
        @task_name = "usasearch:recalls:load_cdc_data"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not given an RSS feed URL" do
        it "should print out an error message" do
          RAILS_DEFAULT_LOGGER.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when given an RSS Feed URL, but not a food type" do
        it "should print out an error message" do
          url = "foo"
          RAILS_DEFAULT_LOGGER.should_receive(:error)
          @rake[@task_name].invoke(url)
        end
      end
      
      context "when given an RSS feed URL and a food type" do
        it "should pass along the url for processing" do
          url = "foo"
          food_type = "food"
          Recall.should_receive(:load_cdc_data_from_rss_feed).with(url, food_type)
          @rake[@task_name].invoke(url, food_type)
        end
      end
    end

    describe "usasearch:recalls:read_cpsc_feed" do
      before do
        @task_name = "usasearch:recalls:read_cpsc_feed"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not given an XML feed URL" do
        it "should print out an error message" do
          RAILS_DEFAULT_LOGGER.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when given an XML Feed URL" do
        it "should send the URL to Recall for processing" do
          url = "foo"
          Recall.should_receive(:load_cpsc_data_from_xml_feed).with(url)
          @rake[@task_name].invoke(url)
        end
      end
    end

    describe "usasearch:recalls:load_cpsc_data" do
      before do
        @task_name = "usasearch:recalls:load_cpsc_data"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not given a CSV file" do
        it "should print out an error message" do
          RAILS_DEFAULT_LOGGER.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when given a CSV file" do
        it "should process the file" do
          Recall.should_receive(:load_cpsc_data_from_file).with("/some/file")
          @rake[@task_name].invoke("/some/file")
        end
      end
    end

    describe "usasearch:recalls:load_nhtsa_data" do
      before do
        @task_name = "usasearch:recalls:load_nhtsa_data"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not given a data file" do
        it "should print out an error message" do
          RAILS_DEFAULT_LOGGER.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when given a data file" do
        it "should process the file" do
          Recall.should_receive(:load_nhtsa_data_from_file).with("/some/file")
          @rake[@task_name].invoke("/some/file")
        end
      end
    end

    describe "usasearch:recalls:read_nhtsa_feed" do
      before do
        @task_name = "usasearch:recalls:read_nhtsa_feed"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not given a feed URL" do
        it "should print out an error message" do
          RAILS_DEFAULT_LOGGER.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when given a Feed URL" do
        it "should send the URL to Recall for processing" do
          url = "foo"
          Recall.should_receive(:load_nhtsa_data_from_tab_delimited_feed).with(url)
          @rake[@task_name].invoke(url)
        end
      end
    end

    describe "usasearch:recalls:load_sample_upc_data" do
      it "should update an existing recall with the appropriate UPC symbol" do
        @task_name = "usasearch:recalls:load_sample_upc_data"
        @recall = Recall.create(:recall_number => '05586', :organization => 'CPSC')
        @rake[@task_name].invoke
        Recall.find_by_recall_number('05586').upc.should == '718103051743'
      end
    end
  end
end
