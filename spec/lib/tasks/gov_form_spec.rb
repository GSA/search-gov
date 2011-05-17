require 'spec/spec_helper'
require "rake"

describe "gov_form rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/gov_form"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:gov_form" do

    describe "usasearch:gov_form:load" do
      before do
        @task_name = "usasearch:gov_form:load"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end
      
      context "when not given an xml file" do
        it "should print out an error message" do
          Rails.logger.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when given an xml file" do
        before do
          @tmp_dir = ::Rails.root.join('tmp', 'test')
          Dir.mkdir(@tmp_dir) unless File.exists?(@tmp_dir)
          @tmp_form1 = <<'EOF'
          <?xml version="1.0" encoding="UTF-8"?>
          <dataroot xmlns:od="urn:schemas-microsoft-com:officedata" generated="2010-01-15T09:09:21">
          <XMLDump>
          <Name>PVO Initial and Annual Registration Form</Name>
          <Form_x0020_Number>AID- 1550-2 </Form_x0020_Number>
          <Agency>Agency for International Development</Agency>
          <Description>Congress requires USAID to collect financial data on private voluntary organizations (PVOs) to compute the percentage or private funding for international programs (privateness test). To collect the data as legislatively mandated by law, USAID utilizes this form to obtain information from PVOs registered with the Agency.</Description>
          <URL>http://www.usaid.gov/our_work/cross-cutting_programs/private_voluntary_cooperation/form1550_2.pdf</URL>
          </XMLDump>
          </dataroot>
EOF
          @tmp_form2 = <<'EOF'
          <?xml version="1.0" encoding="UTF-8"?>
          <dataroot xmlns:od="urn:schemas-microsoft-com:officedata" generated="2010-01-15T09:09:21">
          <XMLDump>
          <Name>PVO Initial and Annual Registration Form</Name>
          <Form_x0020_Number>AID- 1550-2 </Form_x0020_Number>
          <Agency>Agency for International Development</Agency>
          <Bureau>Test Bureau</Bureau>
          <Description>Congress requires USAID to collect financial data on private voluntary organizations (PVOs) to compute the percentage or private funding for international programs (privateness test). To collect the data as legislatively mandated by law, USAID utilizes this form to obtain information from PVOs registered with the Agency.</Description>
          <URL>http://www.usaid.gov/our_work/cross-cutting_programs/private_voluntary_cooperation/form1550_2.pdf</URL>
          </XMLDump>
          </dataroot>
EOF
          @xml_file_name1 = "gov_forms1.xml"
          @xml_file_name2 = "gov_forms2.xml"
          File.open("#{@tmp_dir}/#{@xml_file_name1}", "w+") {|f| f.write(@tmp_form1) }
          File.open("#{@tmp_dir}/#{@xml_file_name2}", "w+") {|f| f.write(@tmp_form2) }
          File.open("#{@tmp_dir}/b", "w+") {|f| f.write(@tmp_forms) }
        end
        
        it "should delete all the existing gov_forms in the table" do
          GovForm.should_receive(:delete_all)
          @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name1}")
        end
        
        it "should create a GovForm entry for each 'XMLDump' element in the file" do
          GovForm.should_receive(:create).exactly(1).times
          @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name1}")
        end
        
        it "should assign the proper values to the proper fields, including stripping whitespace from the form_number field" do
          GovForm.should_receive(:create).with( :name => 'PVO Initial and Annual Registration Form',
                                             :form_number => 'AID- 1550-2',
                                             :agency => 'Agency for International Development',
                                             :bureau => nil,
                                             :description => 'Congress requires USAID to collect financial data on private voluntary organizations (PVOs) to compute the percentage or private funding for international programs (privateness test). To collect the data as legislatively mandated by law, USAID utilizes this form to obtain information from PVOs registered with the Agency.',
                                             :url => 'http://www.usaid.gov/our_work/cross-cutting_programs/private_voluntary_cooperation/form1550_2.pdf')
          @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name1}")
        end

        it "should set the bureau field if present" do          
          GovForm.should_receive(:create).with(:name => 'PVO Initial and Annual Registration Form',
                                               :form_number => 'AID- 1550-2',
                                               :agency => 'Agency for International Development',
                                               :bureau => 'Test Bureau',
                                               :description => 'Congress requires USAID to collect financial data on private voluntary organizations (PVOs) to compute the percentage or private funding for international programs (privateness test). To collect the data as legislatively mandated by law, USAID utilizes this form to obtain information from PVOs registered with the Agency.',
                                               :url => 'http://www.usaid.gov/our_work/cross-cutting_programs/private_voluntary_cooperation/form1550_2.pdf')
          @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name2}")
        end
        
        it "should reindex the GovForms" do
          GovForm.should_receive(:reindex).exactly(1).times
          @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name1}")
        end
          
        after do
          FileUtils.rm_r(@tmp_dir)
        end
        
      end
         
    end
    
    describe "usasearch:gov_form:clean" do
      before do
        GovForm.create!(:name => 'PVO Initial and Annual Registration Form',
                    :form_number => 'AID- 1550-2',
                    :agency => 'Agency for International Development',
                    :description => 'Congress requires USAID to collect financial data on private voluntary organizations (PVOs) to compute the percentage or private funding for international programs (privateness test). To collect the data as legislatively mandated by law, USAID utilizes this form to obtain information from PVOs registered with the Agency.',
                    :url => 'http://www.usaid.gov/our_work/cross-cutting_programs/private_voluntary_cooperation/form1550_2.pdf')
        @task_name = "usasearch:gov_form:clean"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it "should remove all GovForms from database" do
        GovForm.count.should > 0
        @rake[@task_name].invoke
        GovForm.count.should be_zero
      end
    end
    
  end

end
