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

    describe "usasearch:recalls:load" do
      before do
        @task_name = "usasearch:recalls:load"
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
        before do
          @tmp_dir = "/tmp/mydir"
          Dir.mkdir(@tmp_dir) unless File.exists?(@tmp_dir)
          @csv = <<'EOF'
          RecallNo,y2k,Manufacturer,Type,Prname,Seqid,Hazard,Country_mfg,Recdate
          10155,110155,LELE,Clothing (Children),"LELE & Company Maria Elena, Eddie Children’s Princess, Prince, Champion hooded sweatshirt sets",12650,Strangulation,Vietnam,2010-03-03
          10155,110155,Maria Elena,,,12651,,,
          10155,110155,Eddie,,,12652,,,
          10155,110155,Dd’s Discount,,,12653,,,
          10155,110155,Frine Solarzvo,,,12654,,,
          10155,110155,Toro Wholesale,,,12655,,,
          10155,110155,El Carrusel,,,12656,,,
          10155,110155,Hana Hosiery,,,12657,,,
          10155,110155,Lacala Design,,,12658,,,
          10155,110155,La Revoltosa,,,12659,,,
EOF
          @csv_file_path = "#{@tmp_dir}/recalls.csv"
          File.open(@csv_file_path, "w+") {|f| f.write(@csv) }
        end
          
        it "should process the file" do
          Recall.should_receive(:load_from_csv_file).with(@csv_file_path)
          @rake[@task_name].invoke(@csv_file_path)
        end
        
        it "should reindex the Recalls data" do
          Recall.should_receive(:reindex)
          @rake[@task_name].invoke(@csv_file_path)
        end
        
        after do
          FileUtils.rm_r(@tmp_dir)
        end
      end
      
    end
  end
end
