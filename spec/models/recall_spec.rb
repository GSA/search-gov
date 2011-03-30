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

  it { should validate_presence_of :recall_number }
  it { should validate_presence_of :organization }

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
      content = File.read(Rails.root.to_s + "/spec/fixtures/rss/food_recalls.rss")
      response.stub!(:body).and_return(content)
    end

    it "should load food recalls data into DB" do
      Recall.load_cdc_data_from_rss_feed("http://www2c.cdc.gov/podcasts/createrss.asp?c=146", "food")
      first = FoodRecall.first
      first.url.should == "http://www.fda.gov/Safety/Recalls/ucm207477.htm"
      first.summary.should == "Whole Foods Market Voluntarily Recalls Frozen Whole Catch Yellow Fin Tuna Steaks Due to Possible Health Risks"
      first.description.should == "Whole Foods Market announced the recall of its Whole Catch Yellow fin Tuna Steaks (frozen) with a best by date of Dec 5th, 2010 because of possible elevated levels of histamine that may result in symptoms that generally appear within minutes to an hour after eating the affected fish.  No other Whole Foods Market, Whole Catch, 365 or 365 Organic products are affected."
      first.food_type.should == "food"
      first.recall.recalled_on.should == Date.parse("Mon, 05 Apr 2010")
      first.recall.organization.should=='CDC'
      first.recall.recall_number.should_not be_nil
      last = FoodRecall.last
      last.url.should == "http://www.fda.gov/Safety/Recalls/ucm207345.htm"
      last.summary.should == "Golden Pacific Foods, Inc. Issues Allergy Alert for Undeclared Milk and Soy in Marco Polo Brand Shrimp Snacks"
      last.description.should == "Chino, California  (April 2, 2010) -- Golden Pacific Foods, Inc. is recalling Marco Polo Brand Shrimp Snacks sold as Original, Onion & Garlic Flavored and Bar-B-Que Flavored, because they may contain undeclared milk and soy. People who have allergies to milk and soy run the risk of serious or life-threatening reaction if they consume these products."
      last.food_type.should == "food"
      last.recall.recalled_on.should == Date.parse("Sun, 04 Apr 2010")
      last.recall.organization.should=='CDC'
      last.recall.recall_number.should_not be_nil
    end

    it "should skip recalls that have already been loaded" do
      Recall.load_cdc_data_from_rss_feed("http://www2c.cdc.gov/podcasts/createrss.asp?c=146", "food")
      Recall.load_cdc_data_from_rss_feed("http://www2c.cdc.gov/podcasts/createrss.asp?c=146", "food")
      Recall.all.size.should == 2
      FoodRecall.all.size.should == 2
    end

    it "should commit data in Solr so Solr knows to index it" do
      Sunspot.should_receive(:commit)
      Recall.load_cdc_data_from_rss_feed("http://www2c.cdc.gov/podcasts/createrss.asp?c=146", "food")
    end
  end

  describe "#load_cpsc_data_from_file" do
    it "should process each line in the csv file, except the header line" do
      Recall.should_receive(:process_cpsc_row).exactly(10).times
      Recall.load_cpsc_data_from_file("#{File.dirname(__FILE__)}/../fixtures/csv/cpsc_recalls.csv")
    end

    it "should commit data in Solr so Solr knows to index it" do
      Sunspot.should_receive(:commit)
      Recall.load_cpsc_data_from_file("#{File.dirname(__FILE__)}/../fixtures/csv/cpsc_recalls.csv")
    end
  end

  describe "#load_cpsc_data_from_xml_feed" do
    before do
      Net::HTTP.stub!(:get_response).and_return mock("response", :body => File.read(Rails.root.to_s + "/spec/fixtures/xml/cpsc.xml"))
    end

    it "should process each result entry in the file" do
      Recall.should_receive(:process_cpsc_row).twice
      Recall.load_cpsc_data_from_xml_feed("foo")
    end

    it "should commit data in Solr so Solr knows to index it" do
      Sunspot.should_receive(:commit)
      Recall.load_cpsc_data_from_xml_feed("foo")
    end
  end

  describe "#load_nhtsa_data_from_tab_delimited_feed" do
    before do
      Net::HTTP.stub!(:get_response).and_return mock("response", :body => File.read(Rails.root.to_s + "/spec/fixtures/txt/nhtsa_recalls.txt"))
    end

    it "should process each result entry in the file" do
      Recall.should_receive(:process_nhtsa_row).exactly(3).times
      Recall.load_nhtsa_data_from_tab_delimited_feed("foo")
    end

    it "should commit data in Solr so Solr knows to index it" do
      Sunspot.should_receive(:commit)
      Recall.load_nhtsa_data_from_tab_delimited_feed("foo")
    end
  end

  describe "#process_cpsc_row" do
    context "when a recall is seen for the first time" do
      before do
        @row = ['10156', '110156', 'Ethan Allen', "Blinds, Shades & Cords", 'Ethan Allen Design Center Roman Shades', "718103121866", '12660', 'Strangulation', 'United States', '2010-03-04']
      end

      it "should create a new recall" do
        Recall.process_cpsc_row(@row)
        Recall.find_by_recall_number('10156').should_not be_nil
      end

      context "when the UPC is nil" do
        before do
          @row[5] = nil
        end

        it "should create a recall without a UPC recall detail" do
          Recall.process_cpsc_row(@row)
          recall = Recall.find_by_recall_number("10156")
          recall.recall_details.find_by_detail_type('UPC').should be_nil
        end
      end

      context "when the UPC is blank" do
        before do
          @row[5] = ""
        end

        it "should create a recall without a UPC recall detail" do
          Recall.process_cpsc_row(@row)
          recall = Recall.find_by_recall_number("10156")
          recall.recall_details.find_by_detail_type('UPC').should be_nil
        end
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
          @row = ['10156', '110156', 'Ethan Allen', "Blinds, Shades & Cords", 'Ethan Allen Design Center Roman Shades', "718103121866", '12660', 'Strangulation', 'United States']
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
          @recall.recall_details.find_by_detail_type_and_detail_value('Manufacturer', 'Ethan Allen').should_not be_nil
        end

        it "should create a RecallDetail for ProductTypes that are present" do
          @recall.recall_details.find_by_detail_type_and_detail_value('ProductType', 'Blinds, Shades & Cords').should_not be_nil
        end

        it "should create a RecallDetail for Descriptions that are present" do
          @recall.recall_details.find_by_detail_type_and_detail_value('Description', 'Ethan Allen Design Center Roman Shades').should_not be_nil
        end

        it "should create a RecallDetail for UPC codes that are present" do
          @recall.recall_details.find_by_detail_type_and_detail_value('UPC', "718103121866").should_not be_nil
        end

        it "should create a RecallDetail for Hazards that are present" do
          @recall.recall_details.find_by_detail_type_and_detail_value('Hazard', 'Strangulation').should_not be_nil
        end

        it "should create a RecallDetail for Countries that are present" do
          @recall.recall_details.find_by_detail_type_and_detail_value('Country', 'United States').should_not be_nil
        end

      end
    end

    context "when seeing a recall number for the second time" do
      before do
        @row1 = ['10154', '110154', 'American Electric Lighting', 'Lights & Accessories', 'American Electric Lighting AVL Outdoor Lighting Fixtures', "718103121866", '12648', 'Electrocution/Electric Shock', 'Mexico', '2010-03-03']
        @row2 = ['10154', '110154', 'Acuity Brands Lighting', nil, nil, nil, '12649', nil, nil, nil]
        Recall.process_cpsc_row(@row1)
      end

      it "should not create a new Recall" do
        Recall.process_cpsc_row(@row2)
        Recall.find_all_by_recall_number('10154').size.should == 1
      end

      it "should not update the date" do
        recall = Recall.find_by_recall_number('10154')
        Recall.stub!(:find_by_recall_number).and_return recall
        recall.recalled_on.should_not be_nil
        Recall.process_cpsc_row(@row2)
        recall = Recall.find_by_recall_number('10154')
        recall.recalled_on.should_not be_nil
      end

      it "should add RecallDetails to the existing Recall" do
        recall = Recall.find_by_recall_number('10154')
        Recall.stub!(:find_by_recall_number).and_return recall
        Recall.process_cpsc_row(@row2)
        recall.recall_details.find_by_detail_type_and_detail_value('Manufacturer', 'Acuity Brands Lighting').should_not be_nil
      end

      context "when processing recall details that already exist" do
        it "should not create duplicate recall details" do
          Recall.process_cpsc_row(@row1)
          RecallDetail.find_all_by_detail_type_and_detail_value('Manufacturer', 'American Electric Lighting').size.should == 1
        end
      end
    end
  end

  describe "#load_nhtsa_data_from_file" do
    it "should process each line in the file text" do
      Recall.should_receive(:process_nhtsa_row).exactly(3).times
      Recall.load_nhtsa_data_from_file("#{File.dirname(__FILE__)}/../fixtures/txt/nhtsa_recalls.txt")
    end

    it "should commit data in Solr so Solr knows to index it" do
      Sunspot.should_receive(:commit)
      Recall.load_nhtsa_data_from_file("#{File.dirname(__FILE__)}/../fixtures/txt/nhtsa_recalls.txt")
    end
  end

  describe "#process_nhtsa_row" do
    before do
      @row = ["1", "02V269000", "MACK", "CH", "2002", "SCO277", "PARKING BRAKE", "MACK TRUCKS, INCORPORATED", "", "", "V", "557", "20030321", "MFR", "MACK TRUCKS, INC", "20021003", "20021004", "571", "121", "CERTAIN CLASS 8 CHASSIS FAIL TO COMPLY WITH REQUIREMENTS OF FEDERAL MOTOR VEHICLE SAFETY STANDARD NO. 121, \"AIR BRAKE SYSTEMS.\"  THE INSTALLATION OF THE ADDITIONAL AXLE(S), RAISES THE GVW CAPABILITY OF THE VEHICLE AND THEREFORE REQUIRES AN INCREASE IN THE PARKING BRAKE PERFORMANCE TO HOLD ON A 20% GRADE IN ORDER TO MEET THE REQUIREMENTS OF THE STANDARD.", "Consequence Summary", "DEALERS WILL MODIFY THE PARK BRAKE CONFIGURATION ON THESE VEHICLES.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT MACK AT 1-610-709-3337.", "MACK TRUCK RECALL NO. SCO277. CUSTOMERS CAN ALSO CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).", "000015283000097074000000115", "20040608", "PARKING BRAKE PROBLEM"]
    end

    context "when processing a Recall with a Campaign Number that has not already been seen" do
      it "should create a new Recall with the recall number, recall date and organization" do
        Recall.process_nhtsa_row(@row)
        Recall.find_by_recall_number_and_recalled_on_and_organization('02V269000', Date.parse('20040608'), 'NHTSA').should_not be_nil
      end

      it "should use row[24] for the date, unless it's blank, in which case, it should use row[16]" do
        missing_pubdate_row = Array.new(@row)
        missing_pubdate_row[24] = ""
        Recall.process_nhtsa_row(missing_pubdate_row)
        Recall.find_by_recall_number_and_recalled_on_and_organization('02V269000', Date.parse(@row[16]), 'NHTSA').should_not be_nil
      end

      it "should add RecallDetails for each of the full text fields" do
        Recall.process_nhtsa_row(@row)
        recall = Recall.find_by_recall_number_and_recalled_on_and_organization('02V269000', Date.parse('20040608'), 'NHTSA')
        recall.recall_details.size.should == Recall::NHTSA_DETAIL_FIELDS.size
        Recall::NHTSA_DETAIL_FIELDS.each_key do |detail_type|
          recall.recall_details.find_by_detail_type(detail_type).should_not be_nil
        end
      end

      it "should create an AutoRecall for the auto-recall data" do
        @row[8] = "20040608"
        @row[9] = "20040609"
        Recall.process_nhtsa_row(@row)
        ar = AutoRecall.find_by_make_and_model_and_year_and_component_description_and_manufacturer_and_recalled_component_id(
          @row[2], @row[3], @row[4].to_i, @row[6], @row[14], @row[23])
        ar.manufacturing_begin_date.should == Date.parse('20040608')
        ar.manufacturing_end_date.should == Date.parse('20040609')
      end

      it "should set the year to nil if the value supplied is 9999" do
        @row[4] = "9999"
        Recall.process_nhtsa_row(@row)
        AutoRecall.find_by_make_and_model_and_component_description_and_manufacturer_and_recalled_component_id(
          @row[2], @row[3], @row[6], @row[14], @row[23]).year.should be_nil
      end

    end

    context "when processing an NHTSA recall record with a campaign number that we've already seen" do
      before do
        @row2 = ["2", "02V269000", "MACK", "CH", "2002", "SCO277", "PARKING BRAKE", "MACK TRUCKS, INCORPORATED", "", "", "V", "557", "20030321", "MFR", "MACK TRUCKS, INC", "20021003", "20021004", "571", "121", "CERTAIN CLASS 8 CHASSIS FAIL TO COMPLY WITH REQUIREMENTS OF FEDERAL MOTOR VEHICLE SAFETY STANDARD NO. 121, \"AIR BRAKE SYSTEMS.\"  THE INSTALLATION OF THE ADDITIONAL AXLE(S), RAISES THE GVW CAPABILITY OF THE VEHICLE AND THEREFORE REQUIRES AN INCREASE IN THE PARKING BRAKE PERFORMANCE TO HOLD ON A 20% GRADE IN ORDER TO MEET THE REQUIREMENTS OF THE STANDARD.", "", "DEALERS WILL MODIFY THE PARK BRAKE CONFIGURATION ON THESE VEHICLES.   OWNERS WHO TAKE THEIR VEHICLES TO AN AUTHORIZED DEALER ON AN AGREED UPON SERVICE DATE AND DO NOT RECEIVE THE FREE REMEDY WITHIN A REASONABLE TIME SHOULD CONTACT MACK AT 1-610-709-3337.", "MACK TRUCK RECALL NO. SCO277. CUSTOMERS CAN ALSO CONTACT THE NATIONAL HIGHWAY TRAFFIC SAFETY ADMINISTRATION'S AUTO SAFETY HOTLINE AT 1-888-DASH-2-DOT (1-888-327-4236).", "000015283000097074000000116", "20040608", "PARKING BRAKE PROBLEM"]
        Recall.process_nhtsa_row(@row)
      end

      it "should not create a new Recall" do
        Recall.process_nhtsa_row(@row2)
        Recall.find_all_by_recall_number("02V269000").size.should == 1
      end

      context "when the auto recall data already exists in the database" do
        it "should not create duplicate auto recalls" do
          auto_recall_count = Recall.find_by_recall_number("02V269000").auto_recalls.size
          Recall.process_nhtsa_row(@row)
          Recall.find_by_recall_number("02V269000").auto_recalls.size.should == auto_recall_count
        end
      end
    end
  end

  describe ".recent" do
    it "should not pass non recall queries to SOLR" do
      Recall.should_not_receive(:do_search)
      Recall.should_not_receive(:search_for)

      Recall.recent("beef")
    end

    it "should search within the last month" do
      Recall.should_receive(:search_for).with('beef recall', {:start_date=>1.month.ago.to_date, :end_date=>Date.current, :sort => "date"}, 1, 3).and_return(Struct.new(:total).new(5))

      Recall.recent("beef recall").total.should == 5
    end

    it "should retry with no date filter if 0 results in last month" do
      results = [1,2,3]
      Recall.should_receive(:search_for).with('beef recall', {:start_date=>1.month.ago.to_date, :end_date=>Date.current, :sort => "date"}, 1, 3).and_return(Struct.new(:total).new(0))
      Recall.should_receive(:search_for).with('beef recall', {:sort => "date"}, 1, 3).and_return(results)

      Recall.recent("beef recall").should == results
    end

    it "should retry with no date filter if nil results in last month" do
      results = [1,2,3]
      Recall.should_receive(:search_for).with('beef recall', {:start_date=>1.month.ago.to_date, :end_date=>Date.current, :sort => "date"}, 1, 3).and_return(nil)
      Recall.should_receive(:search_for).with('beef recall', {:sort => "date"}, 1, 3).and_return(results)

      Recall.recent("beef recall").should == results
    end

    it "should be nil if no results in either period" do
      Recall.should_receive(:search_for).with('beef recall', {:start_date=>1.month.ago.to_date, :end_date=>Date.current, :sort => "date"}, 1, 3).and_return(nil)
      Recall.should_receive(:search_for).with('beef recall', {:sort => "date"}, 1, 3).and_return(nil)

      Recall.recent("beef recall").should be_nil
    end

  end

  describe ".search_for" do
    before do
      Recall.destroy_all
      Recall.remove_all_from_index!
      @start_date = Date.parse('2010-02-01')
      @number_of_cpsc_recalls = 3
      (@number_of_cpsc_recalls - 1).downto(0) do |index|
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
      Sunspot.commit
    end

    describe "stripping recall terms before sending to Solr" do
      before :each do
        Recall.should_receive(:do_search).with('stroller', {}, 1, 10).at_least(2).times
      end

      it "should strip 'recall'" do
        Recall.search_for('stroller recall')
        Recall.search_for('stroller recalls')
      end

      it "should strip 'retirado' and its forms" do
        Recall.search_for('stroller retirado')
        Recall.search_for('stroller retirada')
        Recall.search_for('stroller retirados')
        Recall.search_for('stroller retiradas')
      end
    end

    describe "when SOLR raises an error" do
      before do
        Recall.should_receive(:do_search).with('sheetrock OR', {}, 1, 10).and_raise(RSolr::RequestError)
      end

      it "should return nil" do
        Recall.search_for("sheetrock OR")
      end
    end


    context "CPSC-related searches" do
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
    end

    context "NHTSA-related searches" do
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

      it "should match terms in the notes field" do
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
    end

    context "when searching by date range" do
      before(:all) do
        @end_date_string = '2010-03-10'
        @end_date = Date.parse(@end_date_string)
        @start_date_string = '2010-02-01'
        @start_date = Date.parse(@start_date_string)
        @query = 'stroller'
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

      context "when sorting by date" do
        it "should be ordered by date descending" do
          search = Recall.search_for("stroller", {:organization => 'CPSC', :sort => 'date'})
          search.results.size.should > 0
          search.results.size.times do |index|
            search.results[index].recalled_on.should be >= search.results[index + 1].recalled_on unless index == (search.total - 1)
          end
        end
      end

      context "when no sort value is specified" do
        it "should order the results by score, with more recent recalls boosted" do
          search = Recall.search_for("stroller", {:organization => 'CPSC'})
          search.results.size.should > 0
          search.results.size.times do |index|
            search.hits[index].score.should == search.hits[index + 1].score unless index == (search.total - 1)
          end
          search.results.size.times do |index|
            search.results[index].recalled_on.should be <= search.results[index + 1].recalled_on unless index == (search.total - 1)
          end
        end
      end
    end

    context "when sorting by relevancy, and two results have about the same relevancy" do
      before do
        Recall.destroy_all
        Recall.remove_all_from_index!

        @older_recall = Recall.create(:recall_number => '12345', :recalled_on => Date.yesterday - 1.month, :organization => 'CPSC')
        @older_recall.recall_details << RecallDetail.new(:detail_type => 'Description', :detail_value => 'This is a really long sentence that includes the word knife which is the keyword that we are looking for.  By putting lots of words in this description, we will make this document have a lower score, and when we boost more recent results, this one will end up lower.')

        @recent_recall = Recall.create(:recall_number => '23456', :recalled_on => Date.yesterday, :organization => 'CPSC')
        @recent_recall.recall_details << RecallDetail.new(:detail_type => 'Description', :detail_value => 'This is a really long sentence that includes the word knife which is the keyword that we are looking for.  They will have about the same score, and when boosted by date, this will be first.')

        Recall.reindex
      end

      it "should return the newer results ahead of the older results" do
        search = Recall.search_for("knife", :organization => 'CPSC')
        search.results.size.should == 2
        search.results.first.should == @recent_recall
        search.results.last.should == @older_recall
      end
    end

    context "CDC food/drug related searches" do
      before do
        Recall.create(:recall_number => Digest::MD5.hexdigest("http://www.fda.gov/Safety/Recalls/ucm216903.htm")[0, 10],
                      :recalled_on => @start_date, :organization => 'CDC',
                      :food_recall => FoodRecall.new(:url=>"http://www.fda.gov/Safety/Recalls/ucm216903.htm",
                                                     :summary=> "Food Recall",
                                                     :description => "Food Recall",
                                                     :food_type => "food"))
        Recall.create(:recall_number => Digest::MD5.hexdigest("http://www.fda.gov/Safety/Recalls/ucm215921.htm")[0, 10],
                      :recalled_on => @start_date, :organization => 'CDC',
                      :food_recall => FoodRecall.new(:url=>"http://www.fda.gov/Safety/Recalls/ucm215921.htm",
                                                     :summary=> "Drug Recall",
                                                     :description => "Drug Recall",
                                                     :food_type => "drug"))
        Recall.reindex
      end

      it "should only retrieve CDC recalls when the organization is set to 'CDC'" do
        search = Recall.search_for("", :organization => "CDC")
        search.total.should == 2
      end

      it "should filter by food type" do
        search = Recall.search_for("recall", :organization => "CDC", :food_type => "food")
        search.total.should == 1
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
        @parsed_recall["upc"].should == ['0123456789']
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
        @recall.food_recall = FoodRecall.new(:url => "RECALL_URL", :summary => "SUMMARY", :description => "DESCRIPTION", :food_type => "FOOD_TYPE")
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
        %w{ recall_url summary description }.each do |field_name|
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

  describe "#summary, #description, #industry" do
    context "when generating a summary for a CPSC recall" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'CPSC')
        products = %w{ Foo Bar Blat }.collect { |product| RecallDetail.new(:detail_type=>"Description", :detail_value=> product.strip) }
        @recall.recall_details << products
        @recall.recall_details << RecallDetail.new(:detail_type=>"ProductType", :detail_value=> "Goo")
      end

      it "should generate a summary based on all the products involved" do
        @recall.summary.should == "Foo, Bar, Blat"
      end
      it "should generate a description based on detail value" do
        @recall.description.should == "Goo"
      end
      it "should have an industry of :product" do
        @recall.industry.should == :product
      end
    end

    context "when generating a summary for a CPSC recall with no product descriptions" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'CPSC')
      end

      it "should generate a summary based on all the products involved" do
        @recall.summary.should == "Click here to see products"
        @recall.description.should be_blank
        @recall.industry.should == :product
      end
    end

    context "when generating a summary for a NHTSA recall" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'NHTSA')
        @recall.auto_recalls = %w{ FOO BAR BLAT }.collect do |str|
          AutoRecall.new(:make => 'AMC',
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
      it "should generate a description" do
        @recall.description.should be_present
      end
      it "should have an industry of :auto" do
        @recall.industry.should == :auto
      end
    end

    context "when generating a summary for a NHTSA recall with no product descriptions" do
      before do
        @recall = Recall.new(:recall_number => '12345', :organization => 'NHTSA')
      end

      it "should generate a summary based on all the products involved" do
        @recall.summary.should == "Click here to see products"
        @recall.description.should be_present
        @recall.industry.should == :auto
      end
    end

    context "when generating a summary for a CDC recall" do
      before do
        @recall = Recall.create(:recall_number => Digest::MD5.hexdigest("http://www.fda.gov/Safety/Recalls/ucm216903.htm")[0, 10],
                                :recalled_on => Date.yesterday, :organization => 'CDC',
                                :food_recall => FoodRecall.new(:url=>"http://www.fda.gov/Safety/Recalls/ucm216903.htm",
                                                               :summary=> "Food Recall Summary Here",
                                                               :description => "Food Recall",
                                                               :food_type => "food"))
      end

      it "should use the underlying FoodRecall summary" do
        @recall.summary.should == "Food Recall Summary Here"
        @recall.description.should be_present
      end

      it "should have an industry of :food" do
        @recall.industry.should == :food
      end

      context "when food_type is 'drug'" do
        before do
          @recall.food_recall.food_type = "drug"
        end

        it "should have an industry of :drug" do
          @recall.industry.should == :drug
        end
      end
    end

    context "when unknown organization" do
      it "should have an industry of :other" do
        Recall.new.industry.should == :other
      end
    end
  end

  describe "#upc" do
    it "should return a list of the RecallDetail UPCs if present" do
      @recall = Recall.new(:recall_number => '12345', :y2k => 12345, :organization => 'CPSC')
      @recall.recall_details << RecallDetail.new(:detail_type => 'UPC', :detail_value => '0123456789')
      @recall.recall_details << RecallDetail.new(:detail_type => 'UPC', :detail_value => '1234567890')
      @recall.save!
      @recall.upc.should_not be_empty
      @recall.upc.size.should == 2
      @recall.upc.first.should == '0123456789'
      @recall.upc.last.should == '1234567890'
    end

    it "should return an empty list if no RecallDetail UPCs are present" do
      @recall = Recall.new(:recall_number => '12345', :y2k => 12345, :organization => 'CPSC')
      @recall.save!
      @recall.upc.should be_empty
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

  describe "#is_food_recall?" do
    before do
      @food_recall = Recall.new(:recall_number => '123444', :organization => 'CDC')
      @non_food_recall = Recall.new(:recall_number => '234566', :organization => 'CPSC')
    end

    it "should return true if the recall is a food recall" do
      @food_recall.is_food_recall?.should be_true
    end

    it "should return false if the recall is not a food recall" do
      @non_food_recall.is_food_recall?.should be_false
    end
  end

  describe "#is_product_recall?" do
    before do
      @product_recall = Recall.new(:recall_number => '123444', :organization => 'CPSC')
      @non_product_recall = Recall.new(:recall_number => '234566', :organization => 'CDC')
    end

    it "should return true if the recall is a food recall" do
      @product_recall.is_product_recall?.should be_true
    end

    it "should return false if the recall is not a food recall" do
      @non_product_recall.is_product_recall?.should be_false
    end
  end

  describe "#is_auto_recall?" do
    before do
      @auto_recall = Recall.new(:recall_number => '123444', :organization => 'NHTSA')
      @non_auto_recall = Recall.new(:recall_number => '234566', :organization => 'CPSC')
    end

    it "should return true if the recall is a food recall" do
      @auto_recall.is_auto_recall?.should be_true
    end

    it "should return false if the recall is not a food recall" do
      @non_auto_recall.is_auto_recall?.should be_false
    end
  end

  describe ".recall_query?" do
    it "should pass for english and spanish variations of the word recall" do
      Recall.should be_recall_query("beef recall")
      Recall.should be_recall_query("beef recalls")
      Recall.should be_recall_query("beef retirado")
      Recall.should be_recall_query("beef retirada")
      Recall.should be_recall_query("beef retirados")
      Recall.should be_recall_query("beef retiradas")
    end

    it "should pass if query is just recall" do
      Recall.should be_recall_query("recall")
      Recall.should be_recall_query("recalls")
    end

    it "should not pass if the query doesn't contain 'recall' or  a translation" do
      Recall.should_not be_recall_query("beef")
      Recall.should_not be_recall_query("rotten beef")
    end
  end

end
