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
          Recall.should_receive(:load_cpsc_data_from_file).with(@csv_file_path)
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
        before do
          @tmp_dir = "/tmp/mydir"
          Dir.mkdir(@tmp_dir) unless File.exists?(@tmp_dir)
          @data = <<'EOF'
          1	02V269000	MACK	CH	2002	SCO277	PARKING BRAKE	MACK TRUCKS, INCORPORATED			V	557	20030321	MFR	MACK TRUCKS, INC	20021003	20021004	571	121 CERTAIN CLASS 8 CHASSIS FAIL TO COMPLY WITH REQUIREMENTS OF FEDERAL MOTOR VEHICLE SAFETY STANDARD NO. 121, "AIR BRAKE SYSTEMS."  THE INSTALLATION OF THE ADDITIONAL AXLE(S), RAISES THE GVW CAPABILITY OF THE VEHICLE AND THEREFORE REQUIRES AN INCREASE IN THE PARKING BRAKE PERFORMANCE TO HOLD ON A 20% GRADE IN ORDER TO MEET THE REQUIREMENTS OF THE STANDARD.		DEALERS WILL MODIFY THE PARK BRAKE CONFIGURATION ON THESE VEHICLES.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT MACK AT 1-610-709-3337.	MACK TRUCK RECALL NO. SCO277. CUSTOMERS CAN ALSO CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).	000015283000097074000000115
          2	02V271000	FLEETWOOD	DISCOVERY	2002		EQUIPMENT:RECREATIONAL VEHICLE	FLEETWOOD ENT., INC.	20010727	20020111	V	69	20021011	MFR	FLEETWOOD ENTERPRISES, INC.	20021003	20021004			ON CERTAIN MOTOR HOMES EQUIPPED WITH OPTION #149 (NORCOLD REFRIGERATORS), THE ELECTRICAL WIRING MAY BE PINCHED AT THE REAR OF THE REFRIGERATOR CAUSING THE WIRING TO SHORT AGAINST OTHER WIRES IN THE AREA OR METAL COMPONENTS OF THE REFRIGERATOR.	THIS COULD CAUSE A FIRE.	DEALERS WILL INSPECT, REPLACE OR REPAIR DAMAGED 110 VOLT AND 12 VOLT WIRES AS NECESSARY.   OWNER NOTIFICATION BEGAN OCTOBER 11, 2002.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT FLEETWOOD AT 1-800-322-8216.	CUSTOMERS CAN ALSO CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).	000015285000096603000000330               
          3	02V164000	COUNTRY COACH	LEXA	2003		EQUIPMENT:ELECTRICAL	COUNTRY COACH INC	20020218	20020228	V	6	20020619	MFR	COUNTRY COACH INC	20020613	20020626			ON CERTAIN MOTOR HOMES EQUIPPED WITH SLIDE-OUT GENERATORS, CERTAIN GENERATOR SLIDE-OUT BALL SCREW ACTUATOR BRAKE HOLDING COMPONENTS ARE DEFECTIVE.  THE BRAKE MAY NOT ALLOW THE ACTUATOR TO HOLD THE LOAD IN POSITION WITH THE POWER OFF.  THE AMOUNT THE LOAD MAY MOVE CAN VARY AND IN SOME CASES THE ACTUATOR MAY NOT HOLD AT ALL.  THESE ACTUATORS ARE USED TO CONTROL THE MOVEMENT OF THE SLIDE-OUT GENERATOR MOUNTED IN THE FRONT OF THE MOTOR HOMES.	THE FAILURE OF THE ACTUATOR TO HOLD THE GENERATOR IN POSITION COULD POTENTIALLY RESULT IN A VEHICLE CRASH AND/OR INJURY TO A PEDESTRIAN.	DEALERS WILL REPLACE THE ACTUATOR.  OWNER NOTIFICATION BEGAN JUNE 19, 2002.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT COUNTRY COACH AT 1-800-452-8015.	ALSO, CUSTOMERS CAN CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).	000015026000106011000000338
EOF
          @data_file_path = "#{@tmp_dir}/nhtsa_recalls.csv"
          File.open(@data_file_path, "w+") {|f| f.write(@data) }
        end

        it "should process the file" do
          Recall.should_receive(:load_nhtsa_data_from_file).with(@data_file_path)
          @rake[@task_name].invoke(@data_file_path)
        end

        it "should reindex the Recalls data" do
          Recall.should_receive(:reindex)
          @rake[@task_name].invoke(@data_file_path)
        end

        after do
          FileUtils.rm_r(@tmp_dir)
        end
      end
    end
  end
end
