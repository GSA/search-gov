require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "faq rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/faq"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:faq" do

    describe "usasearch:faq:load" do
      before do
        @task_name = "usasearch:faq:load"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end
      
      context "when not given an xml file" do
        it "should print out an error message" do
          RAILS_DEFAULT_LOGGER.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when given an xml file" do
        before do
          @tmp_dir = "/tmp/mydir"
          Dir.mkdir(@tmp_dir) unless File.exists?(@tmp_dir)
          @tmp_faq = <<'EOF'
          <?xml version="1.0" encoding="utf-8"?>
          <Report>
            <Field>XML Content Feed</Field>
            <Row>
              <Item>http://www.someurl.com/ananswer.html</Item>
              <Item>Is this a question?</Item>
              <Item>Yes, it is.</Item>
              <Item>1234</Item>
            </Row>
          </Report>
EOF
          @xml_file_name = "faqs.xml"
          File.open("#{@tmp_dir}/#{@xml_file_name}", "w+") {|f| f.write(@tmp_faq) }
          File.open("#{@tmp_dir}/b", "w+") {|f| f.write(@tmp_faq) }
        end
        
        it "should delete all the existing faqs in the table" do
          Faq.should_receive(:delete_all)
          @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name}")
        end
        
        it "should create a Faq entry for each 'Row' in the file" do
          Faq.should_receive(:create).exactly(1).times
          @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name}")
        end
        
        it "should assign the proper values to the proper fields" do
          Faq.should_receive(:create).with( :url => 'http://www.someurl.com/ananswer.html',
                                            :question => 'Is this a question?',
                                            :answer => 'Yes, it is.',
                                            :ranking => 1234)
          @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name}")
        end

        after do
          FileUtils.rm_r(@tmp_dir)
        end
        
      end
         
    end
    
    describe "usasearch:faq:clean" do
      before do
        Faq.create!(:url =>  "http://www.usa.gov",
                    :question => "What is the url of USA.gov?",
                    :answer => 'The URL for USA.gov is http://www.usa.gov',
                    :ranking => 100)
        @task_name = "usasearch:faq:clean"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it "should remove all clicks from database" do
        Faq.count.should > 0
        @rake[@task_name].invoke
        Faq.count.should be_zero
      end
    end
    
  end

end
