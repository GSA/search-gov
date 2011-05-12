require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"


describe "Medline  rake tasks" do

  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/medline"
    Rake::Task.define_task(:environment)
	@empty_vocab = { :topics => {}, :groups => {} }
	@empty_set = {}
  end

  describe "usasearch:medline:lint" do

      before do
        @task_name = "usasearch:medline:lint"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when given a date" do
        it "not throw an exception" do
		  MedTopic.stub!( :lint_medline_xml_for_date )
          @rake[@task_name].invoke("2011-04-26")
        end
      end

      context "when given no date" do
        it "should not throw an exception" do
		  MedTopic.stub!( :lint_medline_xml_for_date )
          @rake[@task_name].invoke()
        end
      end

  end

  describe "usasearch:medline:diff" do

      before do
        @task_name = "usasearch:medline:diff"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when given a from_date and a to_date" do
        it "should not raise an exception" do
		  MedTopic.stub!( :medline_xml_for_date ).and_return ""
		  MedTopic.stub!( :parse_medline_xml_vocab ).and_return @empty_vocab
		  MedTopic.stub!( :delta_medline_vocab ).and_return @empty_set
          @rake[@task_name].invoke("2011-04-19", "2011-04-27")
        end
      end

      context "when given neither a from date nor a to date" do
        it "should not raise an exception" do
		  MedTopic.stub!( :medline_xml_for_date ).and_return ""
		  MedTopic.stub!( :parse_medline_xml_vocab ).and_return @empty_vocab
		  MedTopic.stub!( :dump_db_vocab ).and_return @empty_vocab
		  MedTopic.stub!( :delta_medline_vocab ).and_return @empty_set
          @rake[@task_name].invoke()
        end
      end
  end

  describe "usasearch:medline:load" do

      before do
        @task_name = "usasearch:medline:load"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when given a date" do
        it "should not raise an exception" do
		  MedTopic.stub!( :medline_xml_for_date ).and_return ""
		  MedTopic.stub!( :parse_medline_xml_vocab ).and_return @empty_vocab
		  MedTopic.stub!( :dump_db_vocab ).and_return @empty_vocab
		  MedTopic.stub!( :apply_vocab_delta )
          @rake[@task_name].invoke("2011-04-26")
        end
      end

      context "when given no date" do
        it "should not raise an exception" do
		  MedTopic.should_receive(:medline_xml_for_date).with(nil).and_return ""
		  MedTopic.stub!( :parse_medline_xml_vocab ).and_return @empty_vocab
		  MedTopic.stub!( :dump_db_vocab ).and_return @empty_vocab
		  MedTopic.stub!( :apply_vocab_delta )
          @rake[@task_name].invoke()
        end
      end

  end

end
