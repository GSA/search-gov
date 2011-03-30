require "#{File.dirname(__FILE__)}/../spec_helper"

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
