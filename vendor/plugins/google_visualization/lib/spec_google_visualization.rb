require 'active_support'
require 'spec'
require 'google_visualization.rb'

class CollectionFixture
  attr_accessor :label, :time, :x, :y, :bubble_size, :extra, :extra_2

  def initialize(attributes)
    attributes.each {|key,value| self.send((key.to_s + "=").to_sym, value)}
  end
end

describe GoogleVisualization do
  describe GoogleVisualization::MotionChart do
    before do
      @collection = [CollectionFixture.new(:label => "Monkey", :time => Date.today, :x => 5, :y => 10, :bubble_size => 50, :extra => 1, :extra_2 => 2)]

      @motion_chart = GoogleVisualization::MotionChart.new(self, @collection)
      @motion_chart.label("Department") {|cf| cf.label}
      @motion_chart.time("Time of Year") {|cf| cf.time}
      @motion_chart.x("X Axis") {|cf| cf.x}
      @motion_chart.y("Y Axis") {|cf| cf.y}
      @motion_chart.bubble_size("Bubble Size") {|cf| cf.bubble_size}
      @motion_chart.extra_column("Extra") {|cf| cf.extra }
      @motion_chart.extra_column("Extra 2") {|cf| cf.extra_2 }

      @invalid_motion_chart = GoogleVisualization::MotionChart.new(self, @collection)
    end

    it "should build a valid procedure_hash" do
      @motion_chart.procedure_hash.should be_instance_of(Hash)
      @motion_chart.procedure_hash.should_not be_empty
      @motion_chart.procedure_hash.each do |key,value|
        @motion_chart.procedure_hash[key].should be_instance_of(Array)
        #key.should be_instance_of(Symbol)
	value[0].should be_instance_of(String)
	value[1].should be_instance_of(Proc)
      end
    end

    it "should render valid columns" do
      puts "\n"
      puts @motion_chart.render_columns
    end

    it "should render valid rows" do
      puts "\n"
      puts @motion_chart.render_rows
    end

    it "should raise an exception" do
      lambda {@invalid_motion_chart.render_columns}.should raise_error
    end

  end

  describe GoogleVisualization::AnnotatedTimeLine do
    before do
      @dates = [1.day.ago.to_date, Date.today]
      @line_1_collection = [CollectionFixture.new(:label => "Line 1: Test Title 1", :extra => "Line 1: test note 1", :y => 10), CollectionFixture.new(:label => "Test Title 2", :extra => nil, :y => 15)]
      @line_2_collection = [CollectionFixture.new(:label => "Line 2: Test Title 1", :extra => "Line 2: test note 1", :y => 25), CollectionFixture.new(:label => nil, :extra => "test note 2", :y => 5)]

      @atl = GoogleVisualization::AnnotatedTimeLine.new(self, @dates)
      @atl.add_line("Line 1", @line_1_collection, :value => :y, :title => :label, :notes => :extra)
      @atl.add_line("Line 2", @line_2_collection, :value => :y, :title => :label, :notes => :extra)
    end

    it "should have valid lines" do
      @atl.lines.size.should be_equal(2)
      @atl.lines[0][:collection].size.should >= @atl.instance_variable_get(:@row_length)
      @atl.lines[1][:collection].size.should >= @atl.instance_variable_get(:@row_length)
      @atl.lines[0][:method_hash][:value].should_not be_nil
      @atl.lines[1][:method_hash][:value].should_not be_nil
    end

    it "should render valid columns" do
      puts "\n"
      puts @atl.render
    end
  end

  describe GoogleVisualization::Mappings do
    it "#ruby_to_google_type should produce the correct types" do
      GoogleVisualization::Mappings.ruby_to_google_type(String).should == "string" 
      GoogleVisualization::Mappings.ruby_to_google_type(Date).should == "date" 
      GoogleVisualization::Mappings.ruby_to_google_type(Fixnum).should == "number" 
      GoogleVisualization::Mappings.ruby_to_google_type(Float).should == "number" 
      GoogleVisualization::Mappings.ruby_to_google_type(Time).should == "datetime" 
    end

    it "#ruby_to_javascript_object should produce the correct javascript" do
      GoogleVisualization::Mappings.ruby_to_javascript_object(Date.parse("2008-01-02")).should == "new Date(2008,01,02)" 
      GoogleVisualization::Mappings.ruby_to_javascript_object("my string").should == "'my string'" 
      GoogleVisualization::Mappings.ruby_to_javascript_object(8).should == 8
      GoogleVisualization::Mappings.ruby_to_javascript_object(8.6).should == 8.6
    end

    it "#columns should be a list of symbols" do
      GoogleVisualization::Mappings.columns.should be_instance_of Array
    end
  end
end
