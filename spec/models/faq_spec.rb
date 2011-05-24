require 'spec/spec_helper'

describe Faq do
  before(:each) do
    @valid_attributes = {
      :url => 'http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/std_adp.php?p_faqid=32',
      :question => '&lt;p&gt;Authenticating Documents: Status Request&lt;/p&gt;',
      :answer => '&lt;p&gt;The authentication of documents by the&lt;rn:answer_xref answer_id="203" contents="Office of Authentications" /&gt;&amp;nbsp;at the &lt;rn:answer_xref answer_id="4391" contents="United States Department of State (DOS)" /&gt;&amp;nbsp;takes approximately&amp;nbsp;five busines',
      :ranking => 3248,
      :locale => 'en'
    }
  end

  it "should create a new instance given valid attributes" do
    Faq.create!(@valid_attributes)
  end
  
  it { should validate_presence_of :url }
  it { should validate_presence_of :question }
  it { should validate_presence_of :answer }
  it { should validate_presence_of :ranking }
  it { should validate_presence_of :locale }
  it { should validate_numericality_of :ranking }

  describe "#cached_file_path" do
    it "should return the path to a temporary file based on the parameter provided" do
      Faq.cached_file_path('name.txt').to_s.should == Rails.root.to_s + "/tmp/faq/name.txt"
    end
  end
      
  
  describe "#faq_config" do
    context "when a yaml file exists" do
      before do
        @tmp_dir = ::Rails.root.join( 'tmp', 'faq_test' )
        FileUtils.mkdir_p( @tmp_dir ) unless File.exist?(@tmp_dir)
        @test_faq_config_yaml_path = File.join( @tmp_dir, 'faq_sftp_config.yml' )
        File.open( @test_faq_config_yaml_path, "w") { |yml|
        yml << <<EOF
defaults: &defaults
  protocol: sftp
  dir_path: outbox
  host: localhost
  username: fred
  password: secret
  file_name_pattern:
    en: ^english-faq-[0-9]+.xml$
    es: ^spanish-faq-[0-9]+.xml$

development:
  <<: *defaults

test:
  protocol:
    en: sftp
    es: sftp
    jp: jungledrums
  username:
    en: alice
    es: alicia
  password:
    en: secretalice
    es: secretalicia
  <<: *defaults
EOF
        }
        @expected_test_faq_config = {
            :en => {
                :protocol => 'sftp',
                :host     => 'localhost',
                :username => 'alice',
                :password => 'secretalice',
                :dir_path => 'outbox',
                :file_name_pattern => '^english-faq-[0-9]+.xml$'
            },
            :es => {
                :protocol => 'sftp',
                :host     => 'localhost',
                :username => 'alicia',
                :password => 'secretalicia',
                :dir_path => 'outbox',
                :file_name_pattern => '^spanish-faq-[0-9]+.xml$'
            }
        }
        @expected_faq_download_src = { :en => "outbox/english-faq-20110702.xml", :es => "outbox/spanish-faq-20110702.xml" }
      end

      it "should find the config yml on disk and interpret the config yml correctly given the locale" do
         File.stub!(:join).and_return(@test_faq_config_yaml_path)
         Faq.faq_config('en').should eql @expected_test_faq_config[:en]
         Faq.faq_config('es').should eql @expected_test_faq_config[:es]
      end
    
      it "should throw a runtime error if the locale uses a bad protocol" do
         lambda {
           File.stub!(:join).and_return(@test_faq_config_yaml_path)
           Faq.grab_latest_file( 'jp' )
         }.should raise_error(RuntimeError, "unsupported faq fetch protocol: jungledrums")
      end

      [:en, :es].each do |locale|
        it "should call sftp objects according to the config to retrieve the data for #{locale}" do
           sftp = mock("stfp_session")
           sftp_dir = mock("sftp dir")
           smock0 = mock("ef1")
           smock0.stub!(:name).and_return("README.txt")
           smock1 = mock("ef2")
           smock1.stub!(:name).and_return("english-faq-20110701.xml")
           smock2 = mock("ef3")
           smock2.stub!(:name).and_return("english-faq-20110702.xml")
           smock3 = mock("ef4")
           smock3.stub!(:name).and_return("spanish-faq-20110701.xml")
           smock4 = mock("ef4")
           smock4.stub!(:name).and_return("spanish-faq-20110702.xml")
           smock5 = mock("ef4")
           smock5.stub!(:name).and_return("toc.xml")
           sftp_dir.should_receive(:foreach).with('outbox').and_yield(smock0).and_yield(smock1).and_yield(smock2).and_yield(smock3).and_yield(smock4).and_yield(smock5)
           sftp.stub!(:dir).and_return(sftp_dir)
           sftp_download = mock("sftp download")
           sftp.should_receive(:download!).with(@expected_faq_download_src[locale], "xxx_inc")
           Net::SFTP.stub!(:start).and_yield sftp
           File.stub!(:join).and_return(@test_faq_config_yaml_path)
           Faq.stub(:cached_file_path).and_return "xxx"
           File.should_receive(:rename).with("xxx_inc", "xxx")
           Faq.grab_latest_file( locale.to_s ).should eql "xxx"
        end
      end

      after do
          FileUtils.rm_r(@tmp_dir)
      end
    end
    
    context "when a yaml file does not exist" do
      before do
        @test_not_found_path = File.join('not_found.yml')
      end
      
      it "should return an empty hash if the file is not found" do
        File.stub!(:join).and_return @test_not_found_path
        Faq.faq_config('en').should == {}
        Faq.faq_config('es').should == {}
      end
    end
  end

  describe "#search_for" do
    before do
      # English FAQs
      6.times do
        Faq.create(@valid_attributes)
      end
      # Spanish FAQs
      3.times do
        Faq.create(@valid_attributes.merge(:locale => 'es'))
      end
      Sunspot.commit
      Faq.reindex
    end
    
    context "when searching with only a query" do
      before do
        @search = Faq.search_for('documents')
      end
      
      it "should return three English FAQ results from the first page" do
        @search.results.size.should == 3
        @search.results.each do |result|
          result.locale.should == I18n.default_locale.to_s
        end
      end
    end
    
    context "when searching with a locale" do
      before do
        @search = Faq.search_for('documents', 'es')
      end
      
      it "should only return results that match that locale" do
        @search.results.each do |result|
          result.locale.should == 'es'
        end
      end
    end
    
    context "when searching with a per page parameter" do
      before do
        @search = Faq.search_for('documents', 'en', 2)
      end
      
      it "should return the specified number of results" do
        @search.results.size.should == 2
      end
    end
    
    context "when an error occurs" do
      before do
        Faq.should_receive(:search).and_raise "SomeError"
        @search = Faq.search_for('documents')
      end
      
      it "should return nil" do
        @search.should be_nil
      end
    end
  end
end