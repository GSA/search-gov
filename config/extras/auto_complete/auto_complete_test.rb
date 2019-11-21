require 'spec/spec_helper'

describe "auto_complete" do
  include AutoComplete
  include AutoCompleteMacrosHelper

  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  include ERB::Util

  before do
    @controller = Class.new do
      def url_for(options)
        url =  "http://www.example.com/"
        url << options[:action].to_s if options and options[:action]
        url
      end
    end
    @controller = @controller.new
  end

  describe "test_auto_complete_field" do
    it "should output the appropriate fields based on the parameters" do
      %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', '/affiliates/demo?action=autocomplete', {})\n//]]>\n</script>).should == auto_complete_field("some_input", :url => { :action => "autocomplete" })
      %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', '/affiliates/demo?action=autocomplete', {tokens:','})\n//]]>\n</script>).should == auto_complete_field("some_input", :url => { :action => "autocomplete" }, :tokens => ',')
      %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', '/affiliates/demo?action=autocomplete', {tokens:[',']})\n//]]>\n</script>).should == auto_complete_field("some_input", :url => { :action => "autocomplete" }, :tokens => [','])
      %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', '/affiliates/demo?action=autocomplete', {minChars:3})\n//]]>\n</script>).should == auto_complete_field("some_input", :url => { :action => "autocomplete" }, :min_chars => 3)
      %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', '/affiliates/demo?action=autocomplete', {onHide:function(element, update){alert('me');}})\n//]]>\n</script>).should == auto_complete_field("some_input", :url => { :action => "autocomplete" }, :on_hide => "function(element, update){alert('me');}")
      %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', '/affiliates/demo?action=autocomplete', {frequency:2})\n//]]>\n</script>).should == auto_complete_field("some_input", :url => { :action => "autocomplete" }, :frequency => 2)
      %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', '/affiliates/demo?action=autocomplete', {afterUpdateElement:function(element,value){alert('You have chosen: '+value)}})\n//]]>\n</script>).should == auto_complete_field("some_input", :url => { :action => "autocomplete" }, :after_update_element => "function(element,value){alert('You have chosen: '+value)}")
      %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', '/affiliates/demo?action=autocomplete', {paramName:'huidriwusch'})\n//]]>\n</script>).should == auto_complete_field("some_input", :url => { :action => "autocomplete" }, :param_name => 'huidriwusch')
      %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', '/affiliates/demo?action=autocomplete', {method:'get'})\n//]]>\n</script>).should == auto_complete_field("some_input", :url => { :action => "autocomplete" }, :method => :get)
    end
  end

  describe "#test_auto_complete_result" do
    it "should return the proper results" do
      result = [ { :title => 'test1'  }, { :title => 'test2'  } ]
      %(<ul>&lt;li&gt;test1&lt;/li&gt;&lt;li&gt;test2&lt;/li&gt;</ul>).should == auto_complete_result(result, :title)
      %(<ul>&lt;li&gt;t&lt;strong class=&quot;highlight&quot;&gt;est&lt;/strong&gt;1&lt;/li&gt;&lt;li&gt;t&lt;strong class=&quot;highlight&quot;&gt;est&lt;/strong&gt;2&lt;/li&gt;</ul>).should == auto_complete_result(result, :title, "est")

      resultuniq = [ { :title => 'test1'  }, { :title => 'test1'  } ]
      %(<ul>&lt;li&gt;t&lt;strong class=&quot;highlight&quot;&gt;est&lt;/strong&gt;1&lt;/li&gt;</ul>).should == auto_complete_result(resultuniq, :title, "est")
    end
  end

  describe "test_text_field_with_auto_complete" do
    it "should output the appropriate text field" do
      text_field_with_auto_complete(:message, :recipient).index(%(<style type="text/css">)).should_not be_nil

      %(<input id=\"message_recipient\" name=\"message[recipient]\" size=\"30\" type=\"text\" /><div class=\"auto_complete\" id=\"message_recipient_auto_complete\"></div><script type=\"text/javascript\">\n//<![CDATA[\nvar message_recipient_auto_completer = new Ajax.Autocompleter('message_recipient', 'message_recipient_auto_complete', '/affiliates/demo?action=auto_complete_for_message_recipient', {})\n//]]>\n</script>).should == text_field_with_auto_complete(:message, :recipient, {}, :skip_style => true)
    end
  end
end
