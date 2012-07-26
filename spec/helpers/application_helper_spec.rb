require 'spec/spec_helper'

describe ApplicationHelper do
  before do
    helper.stub!(:image_search?).and_return false
    helper.stub!(:recalls_search?).and_return false
  end

  describe "#other_locale_str" do
    it "should toggle between English and Spanish locales (both strings and symbols)" do
      I18n.locale = :es
      helper.other_locale_str.should == "en"
      I18n.locale = :en
      helper.other_locale_str.should == "es"
      I18n.locale = "es"
      helper.other_locale_str.should == "en"
      I18n.locale = "en"
      helper.other_locale_str.should == "es"
    end
  end

  describe "time_ago_in_words" do
    it "should include 'ago'" do
      time_ago_in_words(4.hours.ago).should == "about 4 hours ago"
      time_ago_in_words(33.days.ago).should == "about 1 month ago"
      time_ago_in_words(2.days.ago).should == "2 days ago"
      time_ago_in_words(1.day.ago).should == "1 day ago"
    end

    context "es" do
      before :each do
        I18n.locale = :es
      end
      after :each do
        I18n.locale = :en
      end
      it "should use the Aproximadamente form" do
        time_ago_in_words(4.hours.ago).should == "Aproximadamente desde hace 4 horas"
        time_ago_in_words(33.days.ago).should == "Aproximadamente desde hace un mes"
        time_ago_in_words(2.days.ago).should == "Desde hace 2 días"
        time_ago_in_words(1.day.ago).should == "Desde ayer"
      end
    end
  end

  describe "localize dates" do
    context "es" do
      before :each do
        I18n.locale = :es
      end
      after :each do
        I18n.locale = :en
      end

      describe "medium localization" do
        it "should look like 29 de enero de 2011" do
          l(Date.parse('2011-01-29'), :format => :medium).should == "29 de enero de 2011"
        end

        (1..12).each do |month|
          it "should work for month #{month}" do
            date = Date.parse("2011-%02i-22" % month)
            l(date, :format => :medium)
          end
        end
      end
    end
  end

  describe "#build_page_title" do
    context "for the English site" do
      before do
        I18n.locale = :en
      end

      context "when a page title is not defined" do
        it "should return the English site title" do
          helper.build_page_title(nil) == (t :site_title)
        end
      end

      context "when a page title is blank" do
        it "should return the English site title" do
          helper.build_page_title("").should == (t :site_title)
        end
      end

      context "when a non-blank page title is defined" do
        it "should prefix the defined page title with the English site title" do
          helper.build_page_title("some title").should == "some title - #{t :serp_title}"
        end
      end

      context "when it's the images page" do
        before do
          helper.stub!(:image_search?).and_return true
        end

        context "when the page title is not defined" do
          it "should return the image title" do
            helper.build_page_title(nil).should == (t :images_site_title)
          end
        end

        context "when a non-blank page title is defined" do
          it "should prefix the defined page title with the English image site title" do
            helper.build_page_title("some title").should == "some title - #{t :images_site_title}"
          end
        end
      end

      context "when it's a recalls page" do
        before do
          helper.stub!(:recalls_search?).and_return true
        end

        context "when the page title is not defined" do
          it "should return the recalls title" do
            helper.build_page_title(nil).should == (t :recalls_site_title)
          end
        end

        context "when a non-blank page title is defined" do
          it "should prefix the defined page title with the English recalls site title" do
            helper.build_page_title("some title").should == "some title - #{t :recalls_site_title}"
          end
        end
      end
    end

    context "for the Spanish site" do
      before do
        I18n.locale = :es
      end

      context "when a page title is not defined" do
        it "should return the Spanish site title" do
          helper.build_page_title(nil) == (t :site_title)
        end
      end

      context "when a page title is blank" do
        it "should return the Spanish site title" do
          helper.build_page_title("").should == (t :site_title)
        end
      end

      context "when a non-blank page title is defined" do
        it "should prefix the defined page title with the Spanish serp title" do
          helper.build_page_title("some title").should == "some title - #{t :serp_title}"
        end
      end

      after do
        I18n.locale = I18n.default_locale
      end
    end
  end

  describe "#current_user_is? for specific role" do
    context "when the current user is an affiliate_admin" do
      it "should detect that" do
        user = stub('User', :is_affiliate_admin? => true)
        helper.stub(:current_user).and_return(user)
        helper.current_user_is?(:affiliate_admin).should be_true
      end
    end

    context "when the current user is an affiliate" do
      it "should detect that" do
        user = stub('User', :is_affiliate? => true)
        helper.stub(:current_user).and_return(user)
        helper.current_user_is?(:affiliate).should be_true
      end
    end

    context "when the current user has no role" do
      it "should detect that" do
        user = stub('User', :is_affiliate_admin? => false, :is_affiliate? => false)
        helper.stub(:current_user).and_return(user)
        helper.current_user_is?(:affiliate).should be_false
        helper.current_user_is?(:affiliate_admin).should be_false
      end
    end

    context "when there is no current user" do
      it "should detect that" do
        helper.stub(:current_user).and_return(nil)
        helper.current_user_is?(:affiliate).should be_false
        helper.current_user_is?(:affiliate_admin).should be_false
      end
    end

  end

  describe "#basic_header_navigation_for" do
    before(:each) do
      helper.stub(:ssl_protocol).and_return("aprotocol")
    end

    context "when user is not logged in" do
      it "should use generate Sign In link with predefined SSL_PROTOCOL" do
        content = helper.basic_header_navigation_for(nil)
        content.should have_selector("a[href^='aprotocol']", :content => "Sign In")
      end

      it "should contain Sign In and Help Desk links" do
        content = helper.basic_header_navigation_for(nil)
        content.should have_selector("a", :content => "Sign In")
        content.should_not have_selector("a", :content => "My Account")
        content.should_not have_selector("a", :content => "Sign Out")
      end
    end

    context "when user is logged in" do
      it "should use generate Sign Out link" do
        user = stub("User", :email => "user@fixtures.org")
        content = helper.basic_header_navigation_for(user)
        content.should have_selector("a[href^='/user_session']", :content => "Sign Out")
      end
    end

    it "should contain My Account and Sign Out links" do
      user = stub("User", :email => "user@fixtures.org")
      content = helper.basic_header_navigation_for(user)
      content.should_not have_selector("a", :content => "Sign In")
      content.should contain("user@fixtures.org")
      content.should have_selector("a", :content => "My Account")
      content.should have_selector("a", :content => "Sign Out")
    end
  end

  describe "#truncate_html_prose_on_words" do
    it "should cope with empty input" do
      [nil, "", "  ", "\n\r\t  \r\n"].each do |empty_ish_xml|
        helper.truncate_html_prose_on_words( empty_ish_xml, 42 ).should == ""
      end
    end

    it "should truncate text" do
      helper.truncate_html_prose_on_words( "this line is too long", 12 ).should == "this line is..."
    end


    it "should not chop up entity refernces" do
      helper.truncate_html_prose_on_words( "this line&nbsp;is&nbsp;too long", 10 ).should == "this..."
      helper.truncate_html_prose_on_words( "this line&nbsp;is&nbsp;too long", 11 ).should == "this..."
      helper.truncate_html_prose_on_words( "this line&nbsp;is&nbsp;too long", 12 ).should == "this..."
      helper.truncate_html_prose_on_words( "this line&nbsp;is&nbsp;too long", 13 ).should == "this..."
    end

    it "should truncate paragraphs" do
      helper.truncate_html_prose_on_words( "<ul><li>this</li><li>list</li><li>is</li><li>too</li><li>long</li></ul>", 42, 3 ).should == "<ul><li>this</li><li>list</li><li>is</li>...</ul>"
    end

    it "should be able to truncate some medline html reasonably well" do
      en_restless_legs_html = "<p>Restless legs syndrome (RLS) causes a powerful urge to move your legs. Your legs become uncomfortable when you are lying down or sitting. Some people describe it as a creeping, crawling, tingling or burning sensation. Moving makes your legs feel better, but not for long.</p><p>In most cases, there is no known cause for RLS. In other cases, RLS is caused by a disease or condition, such as anemia or pregnancy. Some medicines can also cause temporary RLS. Caffeine, tobacco and alcohol may make symptoms worse.</p><p>Lifestyle changes, such as regular sleep habits, relaxation techniques and moderate exercise during the day can help. If those don't work, medicines may reduce the symptoms of RLS.</p>"
      es_tos_html = "<p>La tos es un reflejo que mantiene despejada la garganta y las v&#xED;as respiratorias. Aunque puede ser molesta, la tos ayuda al cuerpo a curarse o protegerse. La tos puede ser aguda o cr&#xF3;nica. La tos aguda comienza s&#xFA;bitamente y no suele durar m&#xE1;s de 2 o 3 semanas. Los cuadros agudos de tos son los que se adquieren frecuentemente con un <a href=\"http://www.nlm.nih.gov/medlineplus/spanish/commoncold.html\">resfr&#xED;o</a> o una <a href=\"http://www.nlm.nih.gov/medlineplus/spanish/flu.html\">gripe</a>. La tos cr&#xF3;nica dura m&#xE1;s de 2 o 3 semanas. Entre las causas de la tos cr&#xF3;nica se encuentran:</p><ul><li><a href=\"http://www.nlm.nih.gov/medlineplus/spanish/asthma.html\">Asma</a></li><li><a href=\"http://www.nlm.nih.gov/medlineplus/spanish/allergy.html\">Alergias</a></li><li><a href=\"http://www.nlm.nih.gov/medlineplus/spanish/copdchronicobstructivepulmonarydisease.html\">Enfermedad pulmonar obstructiva cr&#xF3;nica</a> (EPOC)</li><li><a href=\"http://www.nlm.nih.gov/medlineplus/spanish/smoking.html\">Fumar</a></li><li><a href=\"http://www.nlm.nih.gov/medlineplus/spanish/gerd.html\">Reflujo gastroesof&#xE1;gico</a></li><li><a href=\"http://www.nlm.nih.gov/medlineplus/spanish/throatdisorders.html\">Enfermedades de la garganta</a>, tal como el crup en ni&#xF1;os</li><li>Algunas medicinas</li></ul><p>El agua puede ayudar a mejorar la tos - ya sea que la ingiera o que la agregue al ambiente con un inyector de vapor o un vaporizador. Si esta resfriado o engripado, los antihistam&#xED;nicos pueden dar mejores resultados que los <a href=\"http://www.nlm.nih.gov/medlineplus/spanish/coldandcoughmedicines.html\">medicamentos para la tos sin receta m&#xE9;dica</a>. Los ni&#xF1;os menores de 2 a&#xF1;os no deben recibir medicamentos para la tos. Para ni&#xF1;os mayores de 2 a&#xF1;os, sea precavido y lea cuidadosamente las indicaciones.</p>"

      helper.truncate_html_prose_on_words(en_restless_legs_html, 42).should == "<p>Restless legs syndrome (RLS) causes a...</p>"
      helper.truncate_html_prose_on_words(en_restless_legs_html, 142).should == "<p>Restless legs syndrome (RLS) causes a powerful urge to move your legs. Your legs become uncomfortable when you are lying down or sitting. Some...</p>"
      helper.truncate_html_prose_on_words(en_restless_legs_html, 242).should == "<p>Restless legs syndrome (RLS) causes a powerful urge to move your legs. Your legs become uncomfortable when you are lying down or sitting. Some people describe it as a creeping, crawling, tingling or burning sensation. Moving makes your legs...</p>"

      helper.truncate_html_prose_on_words(es_tos_html, 42).should == "<p>La tos es un reflejo que mantiene...</p>"
      helper.truncate_html_prose_on_words(es_tos_html, 142).should == "<p>La tos es un reflejo que mantiene despejada la garganta y las vías respiratorias. Aunque puede ser molesta, la tos ayuda al cuerpo a curarse o...</p>"
      helper.truncate_html_prose_on_words(es_tos_html, 242).should == "<p>La tos es un reflejo que mantiene despejada la garganta y las vías respiratorias. Aunque puede ser molesta, la tos ayuda al cuerpo a curarse o protegerse. La tos puede ser aguda o crónica. La tos aguda comienza súbitamente y no suele durar...</p>"
      helper.truncate_html_prose_on_words(es_tos_html, 342).should == "<p>La tos es un reflejo que mantiene despejada la garganta y las vías respiratorias. Aunque puede ser molesta, la tos ayuda al cuerpo a curarse o protegerse. La tos puede ser aguda o crónica. La tos aguda comienza súbitamente y no suele durar más de 2 o 3 semanas. Los cuadros agudos de tos son los que se adquieren frecuentemente con un <a href='http://www.nlm.nih.gov/medlineplus/spanish/commoncold.html'>resfrío</a></p>"
      helper.truncate_html_prose_on_words(es_tos_html, 542).should == "<p>La tos es un reflejo que mantiene despejada la garganta y las vías respiratorias. Aunque puede ser molesta, la tos ayuda al cuerpo a curarse o protegerse. La tos puede ser aguda o crónica. La tos aguda comienza súbitamente y no suele durar más de 2 o 3 semanas. Los cuadros agudos de tos son los que se adquieren frecuentemente con un <a href='http://www.nlm.nih.gov/medlineplus/spanish/commoncold.html'>resfrío</a> o una <a href='http://www.nlm.nih.gov/medlineplus/spanish/flu.html'>gripe</a>. La tos crónica dura más de 2 o 3 semanas. Entre las causas de la tos crónica se encuentran:</p><ul><li><a href='http://www.nlm.nih.gov/medlineplus/spanish/asthma.html'>Asma</a></li><li><a href='http://www.nlm.nih.gov/medlineplus/spanish/allergy.html'>Alergias</a></li><li><a href='http://www.nlm.nih.gov/medlineplus/spanish/copdchronicobstructivepulmonarydisease.html'>Enfermedad pulmonar obstructiva crónica</a> (EPOC)</li><li><a href='http://www.nlm.nih.gov/medlineplus/spanish/smoking.html'>Fumar</a></li><li><a href='http://www.nlm.nih.gov/medlineplus/spanish/gerd.html'>Reflujo gastroesofágico</a></li><li><a href='http://www.nlm.nih.gov/medlineplus/spanish/throatdisorders.html'>E...</a></li></ul>"
      helper.truncate_html_prose_on_words(es_tos_html, 542, 2).should == "<p>La tos es un reflejo que mantiene despejada la garganta y las vías respiratorias. Aunque puede ser molesta, la tos ayuda al cuerpo a curarse o protegerse. La tos puede ser aguda o crónica. La tos aguda comienza súbitamente y no suele durar más de 2 o 3 semanas. Los cuadros agudos de tos son los que se adquieren frecuentemente con un <a href='http://www.nlm.nih.gov/medlineplus/spanish/commoncold.html'>resfrío</a> o una <a href='http://www.nlm.nih.gov/medlineplus/spanish/flu.html'>gripe</a>. La tos crónica dura más de 2 o 3 semanas. Entre las causas de la tos crónica se encuentran:</p><ul><li><a href='http://www.nlm.nih.gov/medlineplus/spanish/asthma.html'>Asma</a></li>...</ul>"
    end

    it "should be able to process multibyte characters" do
      helper.truncate_html_prose_on_words("<p>Candy Dynamics Recalls Toxic Waste® Short Circuits™ Bubble Gum</p>", 60).should == "<p>Candy Dynamics Recalls Toxic Waste® Short Circuits™ Bubble...</p>"
      helper.truncate_html_prose_on_words("<p>Candy Dynamics Recalls Toxic Waste® Short Circuits™ Bubble Gum</p>", 51).should == "<p>Candy Dynamics Recalls Toxic Waste® Short Circuits™...</p>"
      helper.truncate_html_prose_on_words("<p>Candy Dynamics Recalls Toxic Waste® Short Circuits™ Bubble Gum</p>", 50).should == "<p>Candy Dynamics Recalls Toxic Waste® Short...</p>"
    end

    # see http://stackoverflow.com/questions/6206885/malformed-utf-8-character-when-calling-rindex-on-string-containing-trademark-sy
    it "should deal with oil spills instead of throwing an exception due to mb character confusion" do
      @oil_spill = "<p>On this page you&#x2019;ll find information about those possible effects and steps you can take to protect yourself and your family.</p>"
      10.upto(11) { |n| helper.truncate_html_prose_on_words(@oil_spill, n).should eql "<p>On this...</p>" }
      12.upto(16) { |n| helper.truncate_html_prose_on_words(@oil_spill, n).should eql "<p>On this page...</p>" }
      17.upto(18) { |n| helper.truncate_html_prose_on_words(@oil_spill, n) }
      19.upto(20) { |n| helper.truncate_html_prose_on_words(@oil_spill, n).should eql "<p>On this page you’ll...</p>" }
    end
  end

  describe "#highlight_like_solr" do
    it "should highlight based on the hit highlights returned from solr" do
      chicken_highlight = Sunspot::Search::Highlight.new(:field_name, "a @@@hl@@@chicken@@@endhl@@@ recall")
      helper.highlight_like_solr("I describe a chicken recall", [chicken_highlight]).should == "I describe a <strong>chicken</strong> recall"
    end

    it "should highlight multiple terms" do
      chicken_wings_highlight = Sunspot::Search::Highlight.new(:field_name, "a @@@hl@@@chicken@@@endhl@@@ @@@hl@@@wings@@@endhl@@@ recall")
      helper.highlight_like_solr("I describe a chicken wings recall", [chicken_wings_highlight]).should == "I describe a <strong>chicken</strong> <strong>wings</strong> recall"
    end

    it "should highlight multiple terms from multiple highlights" do
      one_two_highlight = Sunspot::Search::Highlight.new(:field_name, "@@@hl@@@one@@@endhl@@@ @@@hl@@@two@@@endhl@@@")
      three_highlight = Sunspot::Search::Highlight.new(:field_name, "@@@hl@@@three@@@endhl@@@")
      helper.highlight_like_solr("zero one two three four", [one_two_highlight, three_highlight]).should == "zero <strong>one</strong> <strong>two</strong> <strong>three</strong> four"
    end

    it "should highlight redundant terms just once across multiple highlights" do
      chicken_highlight1 = Sunspot::Search::Highlight.new(:field_name, "a @@@hl@@@chicken@@@endhl@@@ recall")
      chicken_highlight2 = Sunspot::Search::Highlight.new(:field_name, "another @@@hl@@@chicken@@@endhl@@@ problem with all those @@@hl@@@chickens@@@endhl@@@")
      helper.highlight_like_solr("Blah blah chicken is about chickens and the lastest chicken recall", [chicken_highlight1, chicken_highlight2]).should == "Blah blah <strong>chicken</strong> is about <strong>chickens</strong> and the lastest <strong>chicken</strong> recall"
    end

    it "should not highlight word fragements" do
      irs_highlight = Sunspot::Search::Highlight.new(:field_name, "@@@hl@@@IRS@@@endhl@@@")
      helper.highlight_like_solr("the IRS is the first", [irs_highlight]).should == "the <strong>IRS</strong> is the first"
    end

    it "should not highlight anything if term doesn't match" do
      irs_highlight = Sunspot::Search::Highlight.new(:field_name, "@@@hl@@@IRS@@@endhl@@@")
      helper.highlight_like_solr("no matches found", [irs_highlight]).should == "no matches found"
    end
  end

  describe "#url_for_mobile_home_page" do
    it "should return http://m.gobiernousa.gov if locale is set to 'es' and no arguments are given" do
      I18n.should_receive(:locale).and_return('es')
      helper.url_for_mobile_home_page.should == 'http://m.gobiernousa.gov'
    end

    it "should return /?locale=en if locale is set to 'alocale' and no arguments are given" do
      I18n.should_receive(:locale).at_least(:once).and_return('alocale')
      helper.url_for_mobile_home_page.should == '/?locale=alocale&m=true'
    end

    it "should return http://m.gobiernousa.gov when locale argument set to 'es'" do
      helper.url_for_mobile_home_page('es').should == 'http://m.gobiernousa.gov'
    end

    it "should return /?locale=alocale when locale argument set to 'alocale'" do
      helper.url_for_mobile_home_page('alocale').should == '/?locale=alocale&m=true'
    end
  end
end
