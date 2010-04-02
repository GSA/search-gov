require "#{File.dirname(__FILE__)}/../spec_helper"

describe Recall do
  before do
    Recall.destroy_all
    @valid_attributes = {
      :organization => 'CPSC',
      :recall_number => '12345',
      :y2k => 12345,
      :recalled_on => Date.parse('2010-03-01')
    }
  end

  should_validate_presence_of :recall_number, :organization

  it "should create a new instance given valid attributes" do
    Recall.create!(@valid_attributes)
  end

  it "should delete RecallDetails associated with a Recall on deleting a Recall" do
    recall = Recall.new(@valid_attributes)
    recall.recall_details << RecallDetail.new(:detail_type => 'Manufacturer', :detail_value => 'Acme Corp')
    recall.save!
    recall.destroy
    RecallDetail.find(:first, :conditions => ["recall_id = ? AND detail_type = ? AND detail_value = ?", recall.id, 'Manufacturer', 'Acme Corp']).should be_nil
  end

  describe "#load_cdc_data_from_rss_feed" do
    before do
      response = mock("response")
      Net::HTTP.stub!(:get_response).and_return(response)
      content = File.read(RAILS_ROOT + "/spec/fixtures/rss/food_recalls.rss")
      response.stub!(:body).and_return(content)
    end

    it "should load food recalls data into DB" do
      Recall.load_cdc_data_from_rss_feed("http://www2c.cdc.gov/podcasts/createrss.asp?c=146")
      first = FoodRecall.first
      first.url.should == "http://www.fda.gov/Safety/Recalls/ucm207477.htm"
      first.summary.should == "Whole Foods Market Voluntarily Recalls Frozen Whole Catch Yellow Fin Tuna Steaks Due to Possible Health Risks"
      first.description.should == "Whole Foods Market announced the recall of its Whole Catch Yellow fin Tuna Steaks (frozen) with a best by date of Dec 5th, 2010 because of possible elevated levels of histamine that may result in symptoms that generally appear within minutes to an hour after eating the affected fish.  No other Whole Foods Market, Whole Catch, 365 or 365 Organic products are affected."
      first.recall.recalled_on.should == Date.parse("Mon, 05 Apr 2010")
      first.recall.organization.should=='CDC'
      first.recall.recall_number.should_not be_nil
      last = FoodRecall.last
      last.url.should == "http://www.fda.gov/Safety/Recalls/ucm207345.htm"
      last.summary.should == "Golden Pacific Foods, Inc. Issues Allergy Alert for Undeclared Milk and Soy in Marco Polo Brand Shrimp Snacks"
      last.description.should == "Chino, California  (April 2, 2010) -- Golden Pacific Foods, Inc. is recalling Marco Polo Brand Shrimp Snacks sold as Original, Onion & Garlic Flavored and Bar-B-Que Flavored, because they may contain undeclared milk and soy. People who have allergies to milk and soy run the risk of serious or life-threatening reaction if they consume these products."
      last.recall.recalled_on.should == Date.parse("Sun, 04 Apr 2010")
      last.recall.organization.should=='CDC'
      last.recall.recall_number.should_not be_nil
    end

    it "should skip recalls that have already been loaded" do
      Recall.load_cdc_data_from_rss_feed("http://www2c.cdc.gov/podcasts/createrss.asp?c=146")
      Recall.load_cdc_data_from_rss_feed("http://www2c.cdc.gov/podcasts/createrss.asp?c=146")
      Recall.all.size.should == 2
      FoodRecall.all.size.should == 2
    end

    it "should reindex data in Solr" do
      Recall.should_receive(:reindex)
      Recall.load_cdc_data_from_rss_feed("http://www2c.cdc.gov/podcasts/createrss.asp?c=146")
    end
  end

  describe "#load_cpsc_data_from_file" do
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
      @recalls_tmp_file = "recalls.csv"
      File.open("#{@tmp_dir}/#{@recalls_tmp_file}", "w+") {|f| f.write(@csv) }
    end

    it "should process each line in the csv file, except the header line" do
      Recall.should_receive(:process_cpsc_row).exactly(10).times
      Recall.load_cpsc_data_from_file("#{@tmp_dir}/#{@recalls_tmp_file}")
    end

    after do
      FileUtils.rm_r(@tmp_dir)
    end
  end

  describe "#load_cpsc_data_from_text" do
    before do
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
    end

    it "should process each row in the csv text, except the header line" do
      Recall.should_receive(:process_cpsc_row).exactly(10).times
      Recall.load_cpsc_data_from_text(@csv)
    end
  end

  describe "#process_cpsc_row" do
    context "when a recall is seen for the first time" do
      before do
        @row = ['10156', '110156', 'Ethan Allen', "Blinds, Shades & Cords", 'Ethan Allen Design Center Roman Shades', '12660', 'Strangulation', 'United States', '2010-03-04']
      end

      it "should check to see if the recall number already exists in the database" do
        Recall.should_receive(:find_by_recall_number).with('10156').exactly(1).times.and_return nil
        Recall.process_cpsc_row(@row)
      end

      it "should create a new recall if the recall is not found in the database" do
        Recall.process_cpsc_row(@row)
        Recall.find_by_recall_number('10156').should_not be_nil
      end

      context "when a date is present in the CSV row" do
        it "should set the date on the new recall object when date is present in the row" do
          recall = Recall.new(:recall_number => '10156', :y2k => 110156, :organization => 'CPSC')
          Recall.stub!(:new).and_return recall
          Recall.process_cpsc_row(@row)
          recall.recalled_on.should == Date.parse('2010-03-04')
        end

        context "when a date is present, but it does not parse" do
          before do
            @row = ['10156', 110156, 'Ethan Allen', "Blinds, Shades & Cords", 'Ethan Allen Design Center Roman Shades', 12660, 'Strangulation', 'United States', '2010-03-00']
          end

          it "should create a Recall object with a blank date" do
            recall = Recall.new(:recall_number => '10156', :y2k => 110156, :organization => 'CPSC')
            Recall.stub!(:new).and_return recall
            Recall.process_cpsc_row(@row)
            recall.recalled_on.should be_nil
          end
        end
      end

      context "when a date is not present in the CSV row" do
        before do
          @row = ['10156', '110156', 'Ethan Allen', "Blinds, Shades & Cords", 'Ethan Allen Design Center Roman Shades', '12660', 'Strangulation', 'United States']
        end

        it "should not set a date" do
          recall = Recall.new(:recall_number => '10156', :y2k => 110156, :organization => 'CPSC')
          Recall.stub!(:new).and_return recall
          Recall.process_cpsc_row(@row)
          recall.recalled_on.should be_nil
        end
      end

      context "processing recall details" do
        before(:each) do
          @recall = Recall.new(:recall_number => '10156', :y2k => 110156, :organization => 'CPSC')
          Recall.stub!(:new).and_return @recall
          Recall.process_cpsc_row(@row)
        end

        it "should create a RecallDetail for Manufacturers that are present" do
          @recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Manufacturer', 'Ethan Allen']).should_not be_nil
        end

        it "should create a RecallDetail for ProductTypes that are present" do
          recall = Recall.new(:recall_number => '10156', :y2k => 110156, :organization => 'CPSC')
          Recall.stub!(:new).and_return recall
          Recall.process_cpsc_row(@row)
          recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'ProductType', 'Blinds, Shades & Cords']).should_not be_nil
        end

        it "should create a RecallDetail for Descriptions that are present" do
          recall = Recall.new(:recall_number => '10156', :y2k => 110156, :organization => 'CPSC')
          Recall.stub!(:new).and_return recall
          Recall.process_cpsc_row(@row)
          recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Description', 'Ethan Allen Design Center Roman Shades']).should_not be_nil
        end

        it "should create a RecallDetail for Hazards that are present" do
          recall = Recall.new(:recall_number => '10156', :y2k => 110156, :organization => 'CPSC')
          Recall.stub!(:new).and_return recall
          Recall.process_cpsc_row(@row)
          recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Hazard', 'Strangulation']).should_not be_nil
        end

        it "should create a RecallDetail for Countries that are present" do
          recall = Recall.new(:recall_number => '10156', :y2k => 110156, :organization => 'CPSC')
          Recall.stub!(:new).and_return recall
          Recall.process_cpsc_row(@row)
          recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Country', 'United States']).should_not be_nil
        end
      end
    end

    context "when seeing a recall number for the second time" do
      before do
        @row1 = ['10154', '110154', 'American Electric Lighting', 'Lights & Accessories', 'American Electric Lighting AVL Outdoor Lighting Fixtures', '12648', 'Electrocution/Electric Shock', 'Mexico', '2010-03-03']
        @row2 = ['10154', '110154', 'Acuity Brands Lighting', nil, nil, '12649', nil, nil, nil]
        Recall.process_cpsc_row(@row1)
      end

      it "should check to see if the recall number already exists in the database" do
        Recall.process_cpsc_row(@row2)
        Recall.find_by_recall_number("10154").should_not be_nil
      end

      it "should not create a new Recall" do
        Recall.should_not_receive(:new)
        Recall.process_cpsc_row(@row2)
      end

      it "should not update the date" do
        recall = Recall.find_by_recall_number('10154')
        Recall.stub!(:find_by_recall_number).and_return recall
        recall.recalled_on.should_not be_nil
        Recall.process_cpsc_row(@row2)
      end

      it "should add RecallDetails to the existing Recall" do
        recall = Recall.find_by_recall_number('10154')
        Recall.stub!(:find_by_recall_number).and_return recall
        Recall.process_cpsc_row(@row2)
        recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Manufacturer', 'Acuity Brands Lighting']).should_not be_nil
      end
    end
  end

  describe "#load_nhtsa_data_from_file" do
    before do
      @tmp_dir = "/tmp/mydir"
      Dir.mkdir(@tmp_dir) unless File.exists?(@tmp_dir)
      @data = <<'EOF'
      1	02V269000	MACK	CH	2002	SCO277	PARKING BRAKE	MACK TRUCKS, INCORPORATED			V	557	20030321	MFR	MACK TRUCKS, INC	20021003	20021004	571	121 CERTAIN CLASS 8 CHASSIS FAIL TO COMPLY WITH REQUIREMENTS OF FEDERAL MOTOR VEHICLE SAFETY STANDARD NO. 121, "AIR BRAKE SYSTEMS."  THE INSTALLATION OF THE ADDITIONAL AXLE(S), RAISES THE GVW CAPABILITY OF THE VEHICLE AND THEREFORE REQUIRES AN INCREASE IN THE PARKING BRAKE PERFORMANCE TO HOLD ON A 20% GRADE IN ORDER TO MEET THE REQUIREMENTS OF THE STANDARD.		DEALERS WILL MODIFY THE PARK BRAKE CONFIGURATION ON THESE VEHICLES.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT MACK AT 1-610-709-3337.	MACK TRUCK RECALL NO. SCO277. CUSTOMERS CAN ALSO CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).	000015283000097074000000115	20020501	SOMETHING WRONG WITH THE BRAKES
      2	02V271000	FLEETWOOD	DISCOVERY	2002		EQUIPMENT:RECREATIONAL VEHICLE	FLEETWOOD ENT., INC.	20010727	20020111	V	69	20021011	MFR	FLEETWOOD ENTERPRISES, INC.	20021003	20021004			ON CERTAIN MOTOR HOMES EQUIPPED WITH OPTION #149 (NORCOLD REFRIGERATORS), THE ELECTRICAL WIRING MAY BE PINCHED AT THE REAR OF THE REFRIGERATOR CAUSING THE WIRING TO SHORT AGAINST OTHER WIRES IN THE AREA OR METAL COMPONENTS OF THE REFRIGERATOR.	THIS COULD CAUSE A FIRE.	DEALERS WILL INSPECT, REPLACE OR REPAIR DAMAGED 110 VOLT AND 12 VOLT WIRES AS NECESSARY.   OWNER NOTIFICATION BEGAN OCTOBER 11, 2002.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT FLEETWOOD AT 1-800-322-8216.	CUSTOMERS CAN ALSO CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).	000015285000096603000000330	20010405	SOMETHING WRONG WITH THE VEHICLE
      3	02V164000	COUNTRY COACH	LEXA	2003		EQUIPMENT:ELECTRICAL	COUNTRY COACH INC	20020218	20020228	V	6	20020619	MFR	COUNTRY COACH INC	20020613	20020626			ON CERTAIN MOTOR HOMES EQUIPPED WITH SLIDE-OUT GENERATORS, CERTAIN GENERATOR SLIDE-OUT BALL SCREW ACTUATOR BRAKE HOLDING COMPONENTS ARE DEFECTIVE.  THE BRAKE MAY NOT ALLOW THE ACTUATOR TO HOLD THE LOAD IN POSITION WITH THE POWER OFF.  THE AMOUNT THE LOAD MAY MOVE CAN VARY AND IN SOME CASES THE ACTUATOR MAY NOT HOLD AT ALL.  THESE ACTUATORS ARE USED TO CONTROL THE MOVEMENT OF THE SLIDE-OUT GENERATOR MOUNTED IN THE FRONT OF THE MOTOR HOMES.	THE FAILURE OF THE ACTUATOR TO HOLD THE GENERATOR IN POSITION COULD POTENTIALLY RESULT IN A VEHICLE CRASH AND/OR INJURY TO A PEDESTRIAN.	DEALERS WILL REPLACE THE ACTUATOR.  OWNER NOTIFICATION BEGAN JUNE 19, 2002.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT COUNTRY COACH AT 1-800-452-8015.	ALSO, CUSTOMERS CAN CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).	000015026000106011000000338		ELECTRICAL PROBLEMS
EOF
      @recalls_tmp_file = "nhtsa_recalls.csv"
      File.open("#{@tmp_dir}/#{@recalls_tmp_file}", "w+") {|f| f.write(@data) }
    end

    it "should process each line in the file text" do
      Recall.should_receive(:process_nhtsa_row).exactly(3).times
      Recall.load_nhtsa_data_from_file("#{@tmp_dir}/#{@recalls_tmp_file}")
    end

    after do
      FileUtils.rm_r(@tmp_dir)
    end
  end

  describe "#process_nhtsa_row" do
    before do
      @row = ["1", "02V269000", "MACK", "CH", "2002", "SCO277", "PARKING BRAKE", "MACK TRUCKS, INCORPORATED", "", "", "V", "557", "20030321", "MFR", "MACK TRUCKS, INC", "20021003", "20021004", "571", "121", "CERTAIN CLASS 8 CHASSIS FAIL TO COMPLY WITH REQUIREMENTS OF FEDERAL MOTOR VEHICLE SAFETY STANDARD NO. 121, \"AIR BRAKE SYSTEMS.\"  THE INSTALLATION OF THE ADDITIONAL AXLE(S), RAISES THE GVW CAPABILITY OF THE VEHICLE AND THEREFORE REQUIRES AN INCREASE IN THE PARKING BRAKE PERFORMANCE TO HOLD ON A 20% GRADE IN ORDER TO MEET THE REQUIREMENTS OF THE STANDARD.", "Consequence Summary", "DEALERS WILL MODIFY THE PARK BRAKE CONFIGURATION ON THESE VEHICLES.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT MACK AT 1-610-709-3337.", "MACK TRUCK RECALL NO. SCO277. CUSTOMERS CAN ALSO CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).", "000015283000097074000000115", "20040608", "PARKING BRAKE PROBLEM"]
      @recall = Recall.new(:recall_number => '02V269000', :recalled_on => Date.parse('20040608'), :organization => 'NHTSA')
      @auto_recall = AutoRecall.new(:make => @row[2], :model => @row[3], :year => @row[4].to_i, :component_description => @row[6], :manufacturer => @row[14], :recalled_component_id => @row[23])
    end

    context "when processing a Recall with a Campaign Number that has not already been seen" do
      it "should look for the recall by the campaign number" do
        Recall.should_receive(:find_by_recall_number).with("02V269000").and_return nil
        Recall.process_nhtsa_row(@row)
      end

      it "should create a new Recall with the recall number, recall date and organization" do
        Recall.should_receive(:new).with(:recall_number => '02V269000', :recalled_on => Date.parse('20040608'), :organization => 'NHTSA').and_return @recall
        Recall.process_nhtsa_row(@row)
      end

      it "should use row[24] for the date, unless it's blank, in which case, it should use row[16]" do
        @missing_pubdate_row = Array.new(@row)
        @missing_pubdate_row[24] = ""
        Recall.should_receive(:new).with(:recall_number => '02V269000', :recalled_on => Date.parse('20021004'), :organization => 'NHTSA').and_return @recall
        Recall.process_nhtsa_row(@missing_pubdate_row)
      end

      it "should add RecallDetails for each of the full text fields" do
        Recall.stub!(:new).and_return @recall
        Recall.process_nhtsa_row(@row)
        @recall.recall_details.size.should == Recall::NHTSA_DETAIL_FIELDS.size
        Recall::NHTSA_DETAIL_FIELDS.each_key do |detail_type|
          @recall.recall_details.find(:first, :conditions => ['detail_type = ?', detail_type]).should_not be_nil
        end
      end

      it "should create an AutoRecall for the auto-recall data" do
        AutoRecall.should_receive(:new).with(:make => @row[2], :model => @row[3], :year => @row[4].to_i, :component_description => @row[6], :manufacturer => @row[14], :recalled_component_id => @row[23]).and_return @auto_recall
        Recall.process_nhtsa_row(@row)
        @auto_recall.manufacturing_begin_date.should be_nil
        @auto_recall.manufacturing_end_date.should be_nil
      end

      it "should set the year to nil if the value supplied is 9999" do
        auto_recall = @auto_recall
        auto_recall.year = nil
        AutoRecall.should_receive(:new).with(:make => @row[2], :model => @row[3], :year => nil, :component_description => @row[6], :manufacturer => @row[14], :recalled_component_id => @row[23]).and_return auto_recall
        row = @row
        row[4] = 9999
        Recall.process_nhtsa_row(row)
      end


      it "should associate the AutoRecall with the Recall record" do
        Recall.stub!(:new).and_return @recall
        Recall.process_nhtsa_row(@row)
        @recall.auto_recalls.size.should == 1
      end

      it "should save the recall" do
        Recall.stub!(:new).and_return @recall
        @recall.should_receive(:save!)
        Recall.process_nhtsa_row(@row)
      end
    end

    context "when processing an NHTSA recall record with a campaign number that we've already seen" do
      before do
        @row2 = ["2", "02V269000", "MACK", "CH", "2002", "SCO277", "PARKING BRAKE", "MACK TRUCKS, INCORPORATED", "", "", "V", "557", "20030321", "MFR", "MACK TRUCKS, INC", "20021003", "20021004", "571", "121", "CERTAIN CLASS 8 CHASSIS FAIL TO COMPLY WITH REQUIREMENTS OF FEDERAL MOTOR VEHICLE SAFETY STANDARD NO. 121, \"AIR BRAKE SYSTEMS.\"  THE INSTALLATION OF THE ADDITIONAL AXLE(S), RAISES THE GVW CAPABILITY OF THE VEHICLE AND THEREFORE REQUIRES AN INCREASE IN THE PARKING BRAKE PERFORMANCE TO HOLD ON A 20% GRADE IN ORDER TO MEET THE REQUIREMENTS OF THE STANDARD.", "", "DEALERS WILL MODIFY THE PARK BRAKE CONFIGURATION ON THESE VEHICLES.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT MACK AT 1-610-709-3337.", "MACK TRUCK RECALL NO. SCO277. CUSTOMERS CAN ALSO CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).", "000015283000097074000000116", "20040608", "PARKING BRAKE PROBLEM"]
        Recall.process_nhtsa_row(@row)
      end

      it "should not create a new Recall" do
        Recall.should_not_receive(:new)
        Recall.process_nhtsa_row(@row2)
      end

      it "should create an AutoRecall for the auto-recall data" do
        AutoRecall.should_receive(:new).with(:make => @row2[2], :model => @row2[3], :year => @row2[4].to_i, :component_description => @row2[6], :manufacturer => @row2[14], :recalled_component_id => @row2[23]).and_return @auto_recall
        Recall.process_nhtsa_row(@row2)
        @auto_recall.manufacturing_begin_date.should be_nil
        @auto_recall.manufacturing_end_date.should be_nil
      end
    end
  end

  describe "#search_for" do
    integrate_sunspot
    before(:all) do
      Recall.destroy_all
      Recall.remove_all_from_index!
      @start_date = Date.parse('2010-02-01')
      @number_of_cpsc_recalls = 3
      @number_of_cpsc_recalls.times do |index|
        recall = Recall.new(:recall_number => '12345', :y2k => 12345, :recalled_on => @start_date - index.month, :organization => 'CPSC')
        recall.recall_details << RecallDetail.new(:detail_type => 'Manufacturer', :detail_value => 'Acme Corp')
        recall.recall_details << RecallDetail.new(:detail_type => 'ProductType', :detail_value => 'Dangerous Stuff')
        recall.recall_details << RecallDetail.new(:detail_type => 'Description', :detail_value => 'Baby Stroller can be dangerous to children')
        recall.recall_details << RecallDetail.new(:detail_type => 'Hazard', :detail_value => 'Horrible Death')
        recall.recall_details << RecallDetail.new(:detail_type => 'Country', :detail_value => 'United States')
        recall.recall_details << RecallDetail.new(:detail_type => 'UPC', :detail_value => '021200140624')
        recall.save!
      end
      @row = ["1", "02V269000", "MACK", "CH", "2002", "SCO277", "PARKING BRAKE", "MACK TRUCKS, INCORPORATED", "", "", "V", "557", "20030321", "MFR", "MACK TRUCKS, INC", "20021003", "20021004", "571", "121", "CERTAIN CLASS 8 CHASSIS FAIL TO COMPLY WITH REQUIREMENTS OF FEDERAL MOTOR VEHICLE SAFETY STANDARD NO. 121, \"AIR BRAKE SYSTEMS.\"  THE INSTALLATION OF THE ADDITIONAL AXLE(S), RAISES THE GVW CAPABILITY OF THE VEHICLE AND THEREFORE REQUIRES AN INCREASE IN THE PARKING BRAKE PERFORMANCE TO HOLD ON A 20% GRADE IN ORDER TO MEET THE REQUIREMENTS OF THE STANDARD.", "Consequence Summary", "DEALERS WILL MODIFY THE PARK BRAKE CONFIGURATION ON THESE VEHICLES.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT MACK AT 1-610-709-3337.", "MACK TRUCK RECALL NO. SCO277. CUSTOMERS CAN ALSO CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).", "000015283000097074000000115", "20040608", "PARKING BRAKE PROBLEM"]
      @number_of_nhtsa_recalls = 3
      @number_of_nhtsa_recalls.times do |index|
        recall = Recall.new(:recall_number => @row[1], :recalled_on => @start_date - index.month, :organization => 'NHTSA')
        Recall::NHTSA_DETAIL_FIELDS.each_pair do |detail_type, column_index|
          recall.recall_details << RecallDetail.new(:detail_type => detail_type, :detail_value => @row[column_index]) unless @row[column_index].blank?
        end
        recall.auto_recalls << AutoRecall.new(:make => @row[2], :model => @row[3], :year => @row[4])
        recall.save!
      end
    end

    context "CPSC-related searches" do
      before(:all) do
        Recall.reindex
      end

      it "should filter search results by organization" do
        search = Recall.search_for('stroller', {:organization => 'CPSC'})
        search.total.should == @number_of_cpsc_recalls
      end

      it "should find recalls by keywords in the description" do
        search = Recall.search_for('stroller')
        search.total.should == @number_of_cpsc_recalls
      end

      it "should find recalls by keywords in the manufacturer" do
        search = Recall.search_for('acme')
        search.total.should == @number_of_cpsc_recalls
      end

      it "should find recalls by keywords in the recall type" do
        search = Recall.search_for('stuff')
        search.total.should == @number_of_cpsc_recalls
      end

      it "should find recalls by keywords in the hazard" do
        search = Recall.search_for('death')
        search.total.should == @number_of_cpsc_recalls
      end

      it "should find recalls by keywords in the country" do
        search = Recall.search_for('United States')
        search.total.should == @number_of_cpsc_recalls
      end

      it "should find recalls by upc fielded search" do
        search = Recall.search_for(nil, {:upc => '021200140624'})
        search.total.should == @number_of_cpsc_recalls
      end

      it "should facet by Manufacturer" do
        search = Recall.search_for('stroller')
        search.total.should == @number_of_cpsc_recalls
        search.facet(:manufacturer_facet).rows.first.value.should == 'Acme Corp'
        search.facet(:manufacturer_facet).rows.first.count.should == @number_of_cpsc_recalls
      end

      it "should facet by ProductType" do
        search = Recall.search_for('stroller')
        search.total.should == @number_of_cpsc_recalls
        search.facet(:product_type_facet).rows.first.value.should == 'Dangerous Stuff'
        search.facet(:product_type_facet).rows.first.count.should == @number_of_cpsc_recalls
      end

      it "should facet by Hazard" do
        search = Recall.search_for('stroller')
        search.total.should == @number_of_cpsc_recalls
        search.facet(:hazard_facet).rows.first.value.should == 'Horrible Death'
        search.facet(:hazard_facet).rows.first.count.should == @number_of_cpsc_recalls
      end

      it "should facet by Country" do
        search = Recall.search_for('stroller')
        search.total.should == @number_of_cpsc_recalls
        search.facet(:country_facet).rows.first.value.should == 'United States'
        search.facet(:country_facet).rows.first.count.should == @number_of_cpsc_recalls
      end

      it "should facet by recall year" do
        search = Recall.search_for('stroller')
        search.total.should == @number_of_cpsc_recalls
        search.facet(:recall_year).rows.size.should == 2
      end
    end

    context "NHTSA-related searches" do
      before(:all) do
        Recall.reindex
      end

      it "should match terms in the defect summary" do
        search = Recall.search_for("CHASSIS")
        search.total.should == @number_of_nhtsa_recalls
      end

      it "should match terms in the consequence summary" do
        search = Recall.search_for("consequence")
        search.total.should == @number_of_nhtsa_recalls
      end

      it "should match terms in the corrective summary" do
        search = Recall.search_for("dealers")
        search.total.should == @number_of_nhtsa_recalls
      end

      it "should match tersm in the notes field" do
        search = Recall.search_for("highway")
        search.total.should == @number_of_nhtsa_recalls
      end

      it "should field-search on make" do
        search = Recall.search_for(nil, {:make => 'mack'})
        search.total.should == @number_of_nhtsa_recalls
      end

      it "should field-search on model" do
        search = Recall.search_for(nil, {:model => 'ch'})
        search.total.should == @number_of_nhtsa_recalls
      end

      it "should field-search on year" do
        search = Recall.search_for(nil, {:year => 2002})
        search.total.should == @number_of_nhtsa_recalls
      end

      it "should field search on make, model and year combined" do
        search = Recall.search_for(nil, {:make => 'mack', :model => 'ch', :year => 2002})
        search.total.should == @number_of_nhtsa_recalls
      end

      it "should field search on code" do
        search = Recall.search_for(nil, {:code => 'V'})
        search.total.should == @number_of_nhtsa_recalls
      end

      it "should facet by make" do
        search = Recall.search_for("mack")
        search.total.should == @number_of_nhtsa_recalls
        search.facet(:make_facet).rows.size.should == 1
      end

      it "should facet by model" do
        search = Recall.search_for("mack")
        search.total.should == @number_of_nhtsa_recalls
        search.facet(:model_facet).rows.size.should == 1
      end

      it "should facet by year" do
        search = Recall.search_for("mack")
        search.total.should == @number_of_nhtsa_recalls
        search.facet(:year_facet).rows.size.should == 1
      end
    end

    context "when searching by date" do
      before(:all) do
        @end_date_string = '2010-03-10'
        @end_date = Date.parse(@end_date_string)
        @start_date_string = '2010-02-01'
        @start_date = Date.parse(@start_date_string)
        @query = 'stroller'
        Recall.reindex
      end

      it "should search by a date range" do
        search = Recall.search_for(@query, {:start_date => @start_date, :end_date => @end_date})
        search.total.should == 1
      end

      it "should search by a date range without a query" do
        search = Recall.search_for(nil, {:start_date => @start_date, :end_date => @end_date})
        search.total.should == 2
      end

      it "should search by date correctly if the dates are supplied as strings instead of Date objects" do
        search = Recall.search_for(@query, {:start_date => @start_date, :end_date => @end_date})
        search.total.should == 1
      end
    end

    context "when sorting results" do
      context "when sorting by date" do
        it "should be ordered by date descending" do
          search = Recall.search_for("stroller", :sort => "date")
          search.results.each_with_index do |result, index|
            search.results[index].recalled_on.should be >= search.results[index + 1].recalled_on unless index == (search.total - 1)
          end
        end
      end

      context "when no sort value is specified" do
        it "should order the results by score" do
          search = Recall.search_for("stroller")
          search.results.each_with_index do |result, index|
            search.hits[index].score.should be >= search.hits[index + 1].score unless index == (search.total - 1)
          end
        end
      end

      context "when sort by score" do
        it "should order the results by score" do
          search = Recall.search_for("stroller", :sort => "score")
          search.results.each_with_index do |result, index|
            search.hits[index].score.should be >= search.hits[index + 1].score unless index == (search.total - 1)
          end
        end
      end
    end

    after(:all) do
      Recall.remove_all_from_index!
    end
  end

  describe "#to_json" do
    context "for a CPSC recall" do
      before(:all) do
        @recall = Recall.new(:organization => 'CPSC', :recall_number => '12345', :y2k => 12345, :recalled_on => Date.parse('2010-03-01'))
        @recall.recall_details << RecallDetail.new(:detail_type => 'Manufacturer', :detail_value => 'Acme Corp')
        @recall.recall_details << RecallDetail.new(:detail_type => 'ProductType', :detail_value => 'Dangerous Stuff')
        @recall.recall_details << RecallDetail.new(:detail_type => 'Description', :detail_value => 'Baby Stroller can be dangerous to children')
        @recall.recall_details << RecallDetail.new(:detail_type => 'Hazard', :detail_value => 'Horrible Death')
        @recall.recall_details << RecallDetail.new(:detail_type => 'Country', :detail_value => 'United States')
        @recall.recall_details << RecallDetail.new(:detail_type => 'UPC', :detail_value => '0123456789')
        @recall.save!

        @recall_json = "{\"organization\":\"CPSC\",\"upc\":\"0123456789\",\"manufacturers\":[\"Acme Corp\"],\"descriptions\":[\"Baby Stroller can be dangerous to children\"],\"hazards\":[\"Horrible Death\"],\"recall_number\":\"12345\",\"countries\":[\"United States\"],\"recall_date\":\"2010-03-18\",\"product_types\":[\"Dangerous Stuff\"]}"
        @parsed_recall = JSON.parse(@recall.to_json)
      end

      it "should properly parse the organization value" do
        @parsed_recall["organization"].should == 'CPSC'
      end

      it "should properly parse the UPC" do
        @parsed_recall["upc"].should == '0123456789'
      end

      it "should properly parse the recall number" do
        @parsed_recall["recall_number"].should == '12345'
      end

      it "should properly parse the recall date" do
        @parsed_recall["recall_date"].should == '2010-03-01'
      end

      it "should properly parse the recall url" do
        @parsed_recall["recall_url"].should == "http://www.cpsc.gov/cpscpub/prerel/prhtml12/12345.html"
      end

      it "should properly parse the list of manufacturers" do
        @parsed_recall["manufacturers"].should == ['Acme Corp']
      end

      it "should properly parse the list of descriptions" do
        @parsed_recall["descriptions"].should == ["Baby Stroller can be dangerous to children"]
      end

      it "should properly parse the list of hazards" do
        @parsed_recall["hazards"].should == ["Horrible Death"]
      end

      it "should properly parse the list of recall types" do
        @parsed_recall["product_types"].should == ["Dangerous Stuff"]
      end

      it "should properly parse the list of countries" do
        @parsed_recall["countries"].should == ["United States"]
      end
    end

    context "for a NHTSA recall" do
      before(:all) do
        @recall = Recall.new(:organization => 'NHTSA', :recall_number => '12345', :recalled_on => Date.parse('2010-03-01'))
        Recall::NHTSA_DETAIL_FIELDS.each_key do |detail_type|
          @recall.recall_details << RecallDetail.new(:detail_type => detail_type, :detail_value => 'test')
        end
        @recall.auto_recalls << AutoRecall.new(:make => 'TOYOTA', :model => 'CAMRY', :year => '2006', :component_description => 'BRAKES', :manufacturer => 'TOYOTA', :recalled_component_id => '1234567890', :manufacturing_begin_date => Date.parse('2006-01-01'), :manufacturing_end_date => Date.parse('2006-12-31'))
        @recall.auto_recalls << AutoRecall.new(:make => 'TOYOTA', :model => 'SIENA', :year => '2006', :component_description => 'BRAKES', :manufacturer => 'TOYOTA', :recalled_component_id => '1234567890', :manufacturing_begin_date => Date.parse('2006-01-01'), :manufacturing_end_date => Date.parse('2006-12-31'))
        @recall.save!
        @parsed_recall = JSON.parse(@recall.to_json)
      end

      it "should properly parse the organization" do
        @parsed_recall["organization"].should == 'NHTSA'
      end

      it "should properly parse the recall number" do
        @parsed_recall["recall_number"].should == '12345'
      end

      it "should properly parse the recall date" do
        @parsed_recall["recall_date"].should == '2010-03-01'
      end

      it "should properly parse all of the Recall details fields" do
        Recall::NHTSA_DETAIL_FIELDS.each_key do |detail_type|
          @parsed_recall[detail_type.underscore].should == 'test'
        end
      end

      it "should list the associated auto recalls" do
        @parsed_recall["records"].size.should == 2
        @parsed_recall["records"][0]["model"].should == "CAMRY"
        @parsed_recall["records"][1]["model"].should == "SIENA"
      end
    end

    context "for a CDC recall" do
      before(:all) do
        @recall = Recall.new(:organization => 'CDC', :recall_number => '12345', :recalled_on => Date.parse('2010-03-01'))
        @recall.food_recall = FoodRecall.new( :url => "RECALL_URL", :summary => "SUMMARY", :description => "DESCRIPTION")
        @recall.save!
        @parsed_recall = JSON.parse(@recall.to_json)
      end

      it "should properly parse the organization" do
        @parsed_recall["organization"].should == 'CDC'
      end

      it "should properly parse the recall number" do
        @parsed_recall["recall_number"].should == '12345'
      end

      it "should properly parse the recall date" do
        @parsed_recall["recall_date"].should == '2010-03-01'
      end

      it "should properly parse all of the FoodRecall fields" do
        %w{recall_url summary description}.each do |field_name|
          @parsed_recall[field_name].should == field_name.upcase
        end
      end

    end
  end

  describe "#recall_url" do
    context "when generating a recall URL to the press release of a CPSC recall with a recall number" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'CPSC')
      end

      it "should generate a recall URL using the first two digits of the recall number and the recall number to complete the URL" do
        @recall.recall_url.should == "http://www.cpsc.gov/cpscpub/prerel/prhtml12/12345.html"
      end
    end

    context "when generating a recall URL to the press release of a NHTSA recall with a recall number" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'NHTSA')
      end

      it "should generate a recall URL using the first two digits of the recall number and the recall number to complete the URL" do
        @recall.recall_url.should == "http://www-odi.nhtsa.dot.gov/recalls/recallresults.cfm?start=1&SearchType=QuickSearch&rcl_ID=12345&summary=true&PrintVersion=YES"
      end
    end

    context "when generating a recall URL to the press release of a recall without a recall number" do
      before do
        @recall = Recall.new
      end

      it "should return nil" do
        @recall.recall_url.should be_nil
      end
    end

    context "when generating a recall URL for a Recall that is unrecognized" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'BLAH')
      end

      it "should return nil" do
        @recall.recall_url.should be_nil
      end
    end
  end

  describe "#summary" do
    context "when generating a summary for a CPSC recall" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'CPSC')
        products = %w{Foo Bar Blat}.collect { |product| RecallDetail.new(:detail_type=>"Description", :detail_value=> product.strip) }
        @recall.recall_details << products
      end

      it "should generate a summary based on all the products involved" do
        @recall.summary.should == "Foo, Bar, Blat"
      end
    end

    context "when generating a summary for a CPSC recall with no product descriptions" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'CPSC')
      end

      it "should generate a summary based on all the products involved" do
        @recall.summary.should == "Click here to see products"
      end
    end

    context "when generating a summary for a NHTSA recall" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'NHTSA')
        @recall.auto_recalls = %w{FOO BAR BLAT}.collect do |str|
          AutoRecall.new( :make => 'AMC',
                          :model => 'some model',
                          :year => 2006,
                          :component_description => str,
                          :manufacturer => str.succ,
                          :recalled_component_id => '000000000012321320020202V00',
                          :manufacturing_begin_date => Date.parse('2005-01-01'),
                          :manufacturing_end_date => Date.parse('2005-12-31'))
        end
      end

      it "should generate a summary based on all the products involved" do
        @recall.summary.should == "FOO, BAR, BLAT FROM FOP, BAS, BLAU"
      end
    end

    context "when generating a summary for a NHTSA recall with no product descriptions" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'NHTSA')
      end

      it "should generate a summary based on all the products involved" do
        @recall.summary.should == "Click here to see products"
      end
    end

  end

  describe "#upc" do
    it "should return the value of the RecallDetail UPC if present" do
      @recall = Recall.new(:recall_number => '12345', :y2k => 12345, :organization => 'CPSC')
      @recall.recall_details << RecallDetail.new(:detail_type => 'UPC', :detail_value => '0123456789')
      @recall.save!
      @recall.upc.should == '0123456789'
    end

    it "should return 'UNKNOWN' if no RecallDetail is present" do
      @recall = Recall.new(:recall_number => '12345', :y2k => 12345, :organization => 'CPSC')
      @recall.save!
      @recall.upc.should == 'UNKNOWN'
    end

    it "should return nil if organization is not CPSC" do
      @recall = Recall.new(:recall_number => '00001V78', :organization => 'NHTSA')
      @recall.save!
      @recall.upc.should be_nil
    end

    after do
      Recall.destroy_all
    end
  end
end
