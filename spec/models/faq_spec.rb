require "#{File.dirname(__FILE__)}/../spec_helper"

describe Faq do
  before(:each) do
    @valid_attributes = {
      :url => 'http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/std_adp.php?p_faqid=32',
      :question => '&lt;p&gt;Authenticating Documents: Status Request&lt;/p&gt;',
      :answer => '&lt;p&gt;The authentication of documents by the&lt;rn:answer_xref answer_id="203" contents="Office of Authentications" /&gt;&amp;nbsp;at the &lt;rn:answer_xref answer_id="4391" contents="United States Department of State (DOS)" /&gt;&amp;nbsp;takes approximately&amp;nbsp;five busines',
      :ranking => 3248
    }
  end

  it "should create a new instance given valid attributes" do
    Faq.create!(@valid_attributes)
  end
  
  should_validate_presence_of :url, :question, :answer, :ranking
  should_validate_numericality_of :ranking, :only_integer => true
end
