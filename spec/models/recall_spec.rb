require 'spec_helper'

describe Recall do
  before(:each) do
    @valid_attributes = {
      :recall_number => 12345,
      :y2k => 12345,
      :recalled_on => Date.parse('2010-03-01')
    }
  end

  should_validate_presence_of :recall_number, :y2k
  
  it "should create a new instance given valid attributes" do
    Recall.create!(@valid_attributes)
  end
  
  describe "#load_from_csv_file" do
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
      Recall.should_receive(:process_row).exactly(10).times
      Recall.load_from_csv_file("#{@tmp_dir}/#{@recalls_tmp_file}")
    end   
    
    after do
      FileUtils.rm_r(@tmp_dir)
      Recall.destroy_all
      Recall.reindex
    end    
  end
  
  describe "#load_from_text" do
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
      Recall.should_receive(:process_row).exactly(10).times
      Recall.load_from_text(@csv)
    end
    after do
      Recall.destroy_all
      Recall.reindex
    end
  end
    
  describe "#process_row" do
    context "when a recall is seen for the first time" do
      before do
        @row = [10156,110156,'Ethan Allen',"Blinds, Shades & Cords",'Ethan Allen Design Center Roman Shades',12660,'Strangulation','United States','2010-03-04']
      end
    
      it "should check to see if the recall number already exists in the database" do
        Recall.should_receive(:find_by_recall_number).with(10156)
        Recall.process_row(@row)
      end
    
      it "should create a new recall if the recall is not found in the database" do
        Recall.should_receive(:find_by_recall_number).with(10156).exactly(1).times.and_return nil
        Recall.process_row(@row)
      end
    
      context "when a date is present in the CSV row" do
        it "should set the date on the new recall object when date is present in the row" do
          recall = Recall.new(:recall_number => 10156, :y2k => 110156)
          Recall.stub!(:new).and_return recall
          Recall.process_row(@row)
          recall.recalled_on.should == Date.parse('2010-03-04')
        end
      
        context "when a date is present, but it does not parse" do
          before do
            @row = [10156,110156,'Ethan Allen',"Blinds, Shades & Cords",'Ethan Allen Design Center Roman Shades',12660,'Strangulation','United States','2010-03-00']
          end
        
          it "should create a Recall object with a blank date" do
            recall = Recall.new(:recall_number => 10156, :y2k => 110156)
            Recall.stub!(:new).and_return recall
            Recall.process_row(@row)
            recall.recalled_on.should be_nil
          end
        end                    
      end
    
      context "when a date is not present in the CSV row" do
        before do
          @row = [10156,110156,'Ethan Allen',"Blinds, Shades & Cords",'Ethan Allen Design Center Roman Shades',12660,'Strangulation','United States']
        end
      
        it "should not set a date" do
          recall = Recall.new(:recall_number => 10156, :y2k => 110156)
          Recall.stub!(:new).and_return recall
          Recall.process_row(@row)
          recall.recalled_on.should be_nil
        end            
      end
      
      context "processing recall details" do
        
        it "should create a RecallDetail for Manufacturers that are present" do
          recall = Recall.new(:recall_number => 10156, :y2k => 110156)
          Recall.stub!(:new).and_return recall
          Recall.process_row(@row)
          recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Manufacturer', 'Ethan Allen']).should_not be_nil
        end

        it "should create a RecallDetail for RecallTypes that are present" do
          recall = Recall.new(:recall_number => 10156, :y2k => 110156)
          Recall.stub!(:new).and_return recall
          Recall.process_row(@row)
          recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'RecallType', 'Blinds, Shades & Cords']).should_not be_nil
        end

        it "should create a RecallDetail for Descriptions that are present" do
          recall = Recall.new(:recall_number => 10156, :y2k => 110156)
          Recall.stub!(:new).and_return recall
          Recall.process_row(@row)
          recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Description', 'Ethan Allen Design Center Roman Shades']).should_not be_nil
        end

        it "should create a RecallDetail for Hazards that are present" do
          recall = Recall.new(:recall_number => 10156, :y2k => 110156)
          Recall.stub!(:new).and_return recall
          Recall.process_row(@row)
          recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Hazard', 'Strangulation']).should_not be_nil
        end

        it "should create a RecallDetail for Countries that are present" do
          recall = Recall.new(:recall_number => 10156, :y2k => 110156)
          Recall.stub!(:new).and_return recall
          Recall.process_row(@row)
          recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Country', 'United States']).should_not be_nil
        end
      end
    end
    
    context "when seeing a recall number for the second time" do
      before do
        @row1 = [10154,110154,'American Electric Lighting','Lights & Accessories','American Electric Lighting AVL Outdoor Lighting Fixtures',12648,'Electrocution/Electric Shock','Mexico','2010-03-03']
        @row2 = [10154,110154,'Acuity Brands Lighting',nil,nil,12649,nil,nil,nil]
        Recall.process_row(@row1)
      end
      
      it "should check to see if the recall number already exists in the database" do
        Recall.should_receive(:find_by_recall_number).with(10154)
        Recall.process_row(@row2)
      end
     
      it "should not create a new Recall" do
        Recall.should_not_receive(:new)
        Recall.process_row(@row2)
      end
      
      it "should not update the date" do
        recall = Recall.find_by_recall_number(10154)
        Recall.stub!(:find_by_recall_number).and_return recall
        recall.recalled_on.should_not be_nil
        Recall.process_row(@row2)
      end
      
      it "should add RecallDetails to the existing Recall" do
        recall = Recall.find_by_recall_number(10154)
        Recall.stub!(:find_by_recall_number).and_return recall
        Recall.process_row(@row2)
        recall.recall_details.find(:first, :conditions => ['detail_type = ? AND detail_value = ?', 'Manufacturer', 'Acuity Brands Lighting']).should_not be_nil
      end
    end
    
    after do
      Recall.destroy_all
      Recall.reindex
    end
  end
  
  describe "#search_for" do
    integrate_sunspot
    before do
      @start_date = Date.parse('2010-03-01')
      10.times do |index|
        recall = Recall.new(:recall_number => 12345, :y2k => 12345, :recalled_on => @start_date - index.month)
        recall.recall_details << RecallDetail.new(:detail_type => 'Manufacturer', :detail_value => 'Acme Corp')
        recall.recall_details << RecallDetail.new(:detail_type => 'RecallType', :detail_value => 'Dangerous Stuff')
        recall.recall_details << RecallDetail.new(:detail_type => 'Description', :detail_value => 'Baby Stroller can be dangerous to children')
        recall.recall_details << RecallDetail.new(:detail_type => 'Hazard', :detail_value => 'Horrible Death')
        recall.recall_details << RecallDetail.new(:detail_type => 'Country', :detail_value => 'United States')
        recall.save
      end
      Recall.reindex
    end
    
    it "should find recalls by keywords in the description" do
      search = Recall.search_for('stroller')
      search.total.should == 10
    end
    
    it "should find recalls by keywords in the manufacturer" do
      search = Recall.search_for('acme')
      search.total.should == 10
    end
    
    it "should find recalls by keywords in the recall type" do
      search = Recall.search_for('stuff')
      search.total.should == 10
    end
    
    it "should find recalls by keywords in the hazard" do
      search = Recall.search_for('death')
      search.total.should == 10
    end
    
    it "should find recalls by keywords in the country" do
      search= Recall.search_for('United States')
      search.total.should == 10
    end
    
    it "should facet by Manufacturer" do
      search = Recall.search_for('stroller')
      search.total.should == 10
      search.facet(:manufacturer_facet).rows.first.value.should == 'Acme Corp'
      search.facet(:manufacturer_facet).rows.first.count.should == 10
    end

    it "should facet by RecallType" do
      search = Recall.search_for('stroller')
      search.total.should == 10
      search.facet(:recall_type_facet).rows.first.value.should == 'Dangerous Stuff'
      search.facet(:recall_type_facet).rows.first.count.should == 10
    end
    
    it "should facet by Hazard" do
      search = Recall.search_for('stroller')
      search.total.should == 10
      search.facet(:hazard_facet).rows.first.value.should == 'Horrible Death'
      search.facet(:hazard_facet).rows.first.count.should == 10
    end
    
    it "should facet by Country" do
      search = Recall.search_for('stroller')
      search.total.should == 10
      search.facet(:country_facet).rows.first.value.should == 'United States'
      search.facet(:country_facet).rows.first.count.should == 10
    end
    
    it "should facet by year" do
      search = Recall.search_for('stroller')
      search.total.should == 10
      search.facet(:recall_year).rows.size.should == 2
    end
    
    after do
      Recall.destroy_all
      Recall.reindex
    end
  end
  
  describe "#search_for_date_range" do
    integrate_sunspot
    before do
      @start_date = Date.parse('2010-03-01')
      10.times do |index|
        recall = Recall.new(:recall_number => 12345, :y2k => 12345, :recalled_on => @start_date - index.month)
        recall.recall_details << RecallDetail.new(:detail_type => 'Manufacturer', :detail_value => 'Acme Corp')
        recall.recall_details << RecallDetail.new(:detail_type => 'RecallType', :detail_value => 'Dangerous Stuff')
        recall.recall_details << RecallDetail.new(:detail_type => 'Description', :detail_value => 'Baby Stroller can be dangerous to children')
        recall.recall_details << RecallDetail.new(:detail_type => 'Hazard', :detail_value => 'Horrible Death')
        recall.recall_details << RecallDetail.new(:detail_type => 'Country', :detail_value => 'United States')
        recall.save
      end
      Recall.reindex
    end
    
    it "should search by a date range" do
      @start_date = Date.parse('2010-03-10')
      @end_date = Date.parse('2010-01-01')
      search = Recall.search_for_date_range(@start_date, @end_date)
      search.total.should == 3
    end
    
    after do
      Recall.destroy_all
      Recall.reindex
    end
  end
  
  describe "#to_json" do
    before do
      @recall = Recall.new(:recall_number => 12345, :y2k => 12345, :recalled_on => Date.parse('2010-03-01'))
      @recall.recall_details << RecallDetail.new(:detail_type => 'Manufacturer', :detail_value => 'Acme Corp')
      @recall.recall_details << RecallDetail.new(:detail_type => 'RecallType', :detail_value => 'Dangerous Stuff')
      @recall.recall_details << RecallDetail.new(:detail_type => 'Description', :detail_value => 'Baby Stroller can be dangerous to children')
      @recall.recall_details << RecallDetail.new(:detail_type => 'Hazard', :detail_value => 'Horrible Death')
      @recall.recall_details << RecallDetail.new(:detail_type => 'Country', :detail_value => 'United States')
      @recall.save
      
      @recall_json = """{\"manufacturers\":[\"Acme Corp\"],\"descriptions\":[\"Baby Stroller can be dangerous to children\"],\"hazards\":[\"Horrible Death\"],\"recall_number\":12345,\"countries\":[\"United States\"],\"recall_date\":\"2010-03-18\",\"recall_types\":[\"Dangerous Stuff\"]}\""
    end
    
    it "should output well-format JSON" do
      JSON.parse(@recall.to_json)
    end
    
    it "should properly parse the recall number" do
      parsed_recall = JSON.parse(@recall.to_json)
      parsed_recall["recall_number"].should == 12345
    end

    it "should properly parse the recall date" do
      parsed_recall = JSON.parse(@recall.to_json)
      parsed_recall["recall_date"].should == '2010-03-01'
    end

    it "should properly parse the list of manufacturers" do
      parsed_recall = JSON.parse(@recall.to_json)
      parsed_recall["manufacturers"].should == ['Acme Corp']
    end
    
    it "should properly parse the list of descriptions" do
      parsed_recall = JSON.parse(@recall.to_json)
      parsed_recall["descriptions"].should == ["Baby Stroller can be dangerous to children"]
    end
          
    it "should properly parse the list of hazards" do
      parsed_recall = JSON.parse(@recall.to_json)
      parsed_recall["hazards"].should == ["Horrible Death"]
    end

    it "should properly parse the list of recall types" do
      parsed_recall = JSON.parse(@recall.to_json)
      parsed_recall["recall_types"].should == ["Dangerous Stuff"]
    end
    
    it "should properly parse the list of countries" do
      parsed_recall = JSON.parse(@recall.to_json)
      parsed_recall["countries"].should == ["United States"]
    end
    
    after do
      Recall.destroy_all
      Recall.reindex
    end
  end
end
